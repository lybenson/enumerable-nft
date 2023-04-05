// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RoboNFT is ERC721Enumerable, Ownable {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private tokenIds;

  string public unrevealURI;
  string public baseURI;

  // 是否可以开盲盒
  bool public open;
  constructor(
      string memory _name,
      string memory _symbol,
      string memory _baseURI,
      string memory _unrevealURI
  ) ERC721(_name, _symbol) {
    baseURI = _baseURI;
    unrevealURI = _unrevealURI;
    tokenIds.increment();
  }

  function setBaseURI(string memory _baseURI) external onlyOwner {
    baseURI = _baseURI;
  }
  function setUnrevealURI(string memory _unrevealURI) external onlyOwner {
    unrevealURI = _unrevealURI;
  }

  function setOpen(bool _open) external onlyOwner {
    open = _open;
  }

  function mint(address _to) public returns(uint) {
    require(tx.origin == owner(), "You can not mint");
    uint tokenId = tokenIds.current();
    _safeMint(_to, tokenId);

    tokenIds.increment();

    return tokenId;
  }

  function tokenURI(uint256 tokenId) public override view returns(string memory) {
    require(_exists(tokenId), 'Token not minted');

    // 未到时间不能开盲盒
    if (!open) return unrevealURI;

    // 存在 baseURI 则进行拼接
    if (bytes(baseURI).length > 0) {
      return string(abi.encodePacked(baseURI, tokenId.toString()));
    }
    return unrevealURI;
  }
  
  // 获取某个地址拥有的 nft 列表
  function getTokenIds(address _owner) public view returns (uint[] memory) {
    uint[] memory _tokensOfOwner = new uint[](ERC721.balanceOf(_owner));
    uint balance = balanceOf(_owner);

    for (uint i=0; i < balance; i++) {
        _tokensOfOwner[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return _tokensOfOwner;
  }
}
