pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {SimpleBankOptimized} from "../src/SimpleBankOptimized.sol";

contract SimpleBankOptimizedTest is Test {
    SimpleBankOptimized public bank;

    function setUp() public {
        bank = new SimpleBankOptimized();
    }

    receive() external payable {}

    function test_Deposit() public {
        // Setup saldo yang akan didepositkan
        uint256 depositAmount = 1 ether;

        // console.log("Before deposit:");
        // console.log("Balance:", bank.balances(address(this)));

        // Act: Perform action, pake adress contract
        vm.deal(address(this), depositAmount); // isi kontrak dengan ETH
        bank.deposit{value: depositAmount}(); //do deposit

        // console.log("After deposit:");
        // console.log("Balance:", bank.balances(address(this)));

        // cek pakai simulasi walltet
        address user = vm.addr(1);
        vm.deal(user, depositAmount); // isi wallet user dengan ETH
        vm.prank(user); // ganti msg.sender ke user
        bank.deposit{value: depositAmount}(); // user do deposit

        // Assert: Verify results
        assertEq(bank.balances(address(this)), depositAmount); // cek apakah balance update?
        assertEq(bank.balances(user), depositAmount); // cek apakah balance update?
        assertEq(bank.getTotalDeposits(), depositAmount * 2); // cek total deposit
    }

    function test_DepositEmitsEvent() public {
        uint256 depositAmount = 1 ether;

        // Expect event to be emitted
        vm.expectEmit(true, false, false, true);
        emit SimpleBankOptimized.Deposited(address(this), depositAmount);

        vm.deal(address(this), depositAmount);
        bank.deposit{value: depositAmount}();
    }

    function test_RevertWhen_DepositZero() public {
        // Expect revert with specific error
        vm.expectRevert(SimpleBankOptimized.ZeroAmount.selector);

        // Try to deposit 0
        bank.deposit{value: 0}();
    }

    function test_Withdraw() public {
        // Setup: Deposit first
        uint256 depositAmount = 10 ether;
        uint256 withdrawAmount = 3 ether;

        vm.deal(address(this), depositAmount);
        bank.deposit{value: depositAmount}();

        // Record balance before withdraw
        uint256 balanceBefore = address(this).balance;

        // Withdraw
        bank.withdraw(withdrawAmount);

        // // Assert
        assertEq(bank.balances(address(this)), depositAmount - withdrawAmount);
        assertEq(address(this).balance, balanceBefore + withdrawAmount);
    }

    function test_RevertWhen_WithdrawInsufficientBalance() public {
        // Deposit 5 ETH
        vm.deal(address(this), 5 ether);
        bank.deposit{value: 5 ether}();

        // Try to withdraw 10 ETH (more than balance)
        vm.expectRevert(
            abi.encodeWithSelector(
                SimpleBankOptimized.InsufficientBalance.selector,
                10 ether, // requested
                5 ether // available
            )
        );
        bank.withdraw(10 ether);
    }

    function test_TransferEmitsEvent() public {
        address alice = address(0x1);
        address bob = address(0x2);

        vm.deal(alice, 10 ether);
        vm.prank(alice);
        bank.deposit{value: 10 ether}();

        // Expect event
        vm.expectEmit(true, true, false, true);
        emit SimpleBankOptimized.Transferred(alice, bob, 3 ether);

        vm.prank(alice);
        bank.transfer(bob, 3 ether);
    }

    function testFuzz_Deposit(uint256 amount) public {
        // Foundry akan call function ini dengan random 'amount'

        // Skip if amount is 0 (will revert)
        vm.assume(amount > 0);
        vm.assume(amount <= 1000 ether); // Reasonable upper limit

        vm.deal(address(this), amount);
        bank.deposit{value: amount}();

        assertEq(bank.balances(address(this)), amount);
    }

    function testFuzz_Withdraw(
        uint256 depositAmount,
        uint256 withdrawAmount
    ) public {
        // Constraints
        vm.assume(depositAmount > 0 && depositAmount <= 1000 ether);
        vm.assume(withdrawAmount > 0 && withdrawAmount <= depositAmount);

        // Deposit
        vm.deal(address(this), depositAmount);
        bank.deposit{value: depositAmount}();

        // Withdraw
        bank.withdraw(withdrawAmount);

        // Assert
        assertEq(bank.balances(address(this)), depositAmount - withdrawAmount);
    }

    function testFuzz_TransferBetweenUsers(
        address alice,
        address bob,
        uint256 depositAmount,
        uint256 transferAmount
    ) public {
        // Constraints
        vm.assume(alice != address(0) && bob != address(0));
        vm.assume(alice != bob);
        vm.assume(depositAmount > 0 && depositAmount <= 1000 ether);
        vm.assume(transferAmount > 0 && transferAmount <= depositAmount);

        // Alice deposits
        vm.deal(alice, depositAmount);
        vm.prank(alice);
        bank.deposit{value: depositAmount}();

        // Alice transfers to Bob
        vm.prank(alice);
        bank.transfer(bob, transferAmount);

        // Assert
        assertEq(bank.balances(alice), depositAmount - transferAmount);
        assertEq(bank.balances(bob), transferAmount);
    }

    function test_RevertWhen_WithdrawZero() public {
        vm.deal(address(this), 5 ether);
        bank.deposit{value: 5 ether}();

        vm.expectRevert(SimpleBankOptimized.ZeroAmount.selector);
        bank.withdraw(0);
    }

    function test_Transfer() public {
        address alice = address(0x1);
        address bob = address(0x2);

        vm.deal(alice, 10 ether);
        vm.prank(alice);
        bank.deposit{value: 10 ether}();

        vm.prank(alice);
        bank.transfer(bob, 3 ether);

        assertEq(bank.balances(alice), 7 ether);
        assertEq(bank.balances(bob), 3 ether);
    }

    function test_RevertWhen_TransferZero() public {
        vm.deal(address(this), 5 ether);
        bank.deposit{value: 5 ether}();

        vm.expectRevert(SimpleBankOptimized.ZeroAmount.selector);
        bank.transfer(address(0x1), 0);
    }

    function test_RevertWhen_TransferInsufficientBalance() public {
        vm.deal(address(this), 5 ether);
        bank.deposit{value: 5 ether}();

        vm.expectRevert(
            abi.encodeWithSelector(
                SimpleBankOptimized.InsufficientBalance.selector,
                10 ether,
                5 ether
            )
        );
        bank.transfer(address(0x1), 10 ether);
    }

    function test_GetBalance() public {
        address user = address(0x1);
        vm.deal(user, 5 ether);
        vm.prank(user);
        bank.deposit{value: 5 ether}();

        assertEq(bank.getBalance(user), 5 ether);
    }
}
