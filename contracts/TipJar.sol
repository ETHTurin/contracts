// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TipJar is ERC1155, Ownable {
  using SafeMath for uint256;

  struct Range { 
    uint256 min; // Minimum amount of ether (in wei) to get this token
    uint256 max; // Maximum amount of ether (in wei) to get this token
    bool exists; // To check if token id exists
  }

  uint256 public noOfTokens;
  uint256 public totalReceivedAmount;

  uint256[] public tokenIds;

  // Mapping from token ID to token prices in wei
  mapping (uint256 => uint256) public prices;

  // Mapping from token ID to amount range (maximum inclusive) in wei for the token eligibility
  mapping (uint256 => Range) public priceRanges;

  // Mapping from token ID to active token supply
  mapping (uint256 => uint256) public tokenSupply;

  event TokenRangeUpdated(address indexed actor, uint256 indexed tokenId, uint256 oldMin, uint256 oldMax, uint256 newMin, uint256 newMax);
  event TokenPriceUpdated(address indexed actor, uint256 indexed tokenId, uint price);
  event RightsPaymentReceived(address indexed payer, uint256 value);

  constructor(string memory uri) ERC1155(uri) {}

  function createTokenWithRange(uint256 min, uint256 max) onlyOwner external {
    require(min != max, "ERC1155Final: min cannot be equal to max");
    noOfTokens++;
    tokenIds.push(noOfTokens);
    priceRanges[noOfTokens] = Range(min, max, true);
    emit TokenRangeUpdated(msg.sender, noOfTokens, 0, 0, min, max);
  }

  function updateTokenWithRange(uint256 tokenId, uint256 newMin, uint256 newMax) onlyOwner external {
    require(priceRanges[tokenId].exists, "ERC1155Final: tokenId does not exist");
    emit TokenRangeUpdated(msg.sender, tokenId, priceRanges[tokenId].min, priceRanges[tokenId].max, newMin, newMax);
    priceRanges[tokenId].min = newMin;
    priceRanges[tokenId].max = newMax;
  }

  function setTokenPrice(uint256 tokenId, uint256 priceInWei) onlyOwner external {
    require(priceRanges[tokenId].exists, "ERC1155Final: tokenId does not exist");
    prices[tokenId] = priceInWei;
    emit TokenPriceUpdated(msg.sender, tokenId, priceInWei);
  }

  function setURI(string memory newuri) onlyOwner external {
    super._setURI(newuri);
  }

  function mint(address account, uint256 id, uint256 amount, bytes memory data) internal {
    super._mint(account, id, amount, data);
  }

  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
    super._mintBatch(to, ids, amounts, data);
  }
}