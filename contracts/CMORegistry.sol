//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./TipJar.sol";

/** @title CMORegistry: registry that keeps track of the deposited copyrights and the related payments */
contract CMORegistry is TipJar {
  using SafeMath for uint256;

  struct RegistrationInfo {
    address payable[] owners;
    uint8[] shares;
  }

  mapping (address => string[]) public ownersToRights;
  mapping (string => RegistrationInfo) rightsToOwners;

  string[] public rightsCids;
  uint public numOfCids;

  event RightRegistered(string _cid, address payable[] _owners, uint8[] _shares);

  constructor(string memory _tokenUri) TipJar(_tokenUri) {}

  /** @dev            Submits the IPFS content hash of something that has to be registered on chain
   *  @param _cid     The IPFS content hash of the something to be registered
   *  @param _owners  Array of addresses which own a share of the content
   *  @param _shares  Array of shares owned by a certain address
   */
  function submitCid(string memory _cid, address payable[] memory _owners, uint8[] memory _shares) public {
    require(_owners.length == _shares.length, "Each owner should have its corresponding share");

    uint8 sharesTotal = 0;
    for(uint8 i = 0; i < _shares.length; i++) {
      sharesTotal += _shares[i];
    }
    require(sharesTotal == 100, 'Sum of shares must be exactly 100');

    RegistrationInfo memory regInfo = RegistrationInfo({owners: _owners, shares: _shares});
    
    rightsToOwners[_cid] = regInfo;

    for(uint8 i = 0; i < _owners.length; i++) {
      string[] storage rights = ownersToRights[_owners[i]];
      rights.push(_cid);
      ownersToRights[_owners[i]] = rights;
    }

    rightsCids.push(_cid);
    numOfCids++;

    emit RightRegistered(_cid, _owners, _shares);
  }

  /** @dev                    Returns infos about owners and their shares for a certain content
   *  @param _cid             IPFS content hash to get info for
   *  @return _copyrightInfo  The info about that content
   */
  function getRightsOwnersForCid(string memory _cid) public view returns (RegistrationInfo memory _copyrightInfo) {
    return rightsToOwners[_cid];
  }


  /** @dev            Pays the necessary share in order to access some rights and mints an NFT that certify the ownership
   *  @param _cids    Array of IPFS content hashes of the rights to be used
   */
  function payRights(string[] memory _cids) payable public {
      uint256 value = msg.value;

      for(uint8 i = 0; i < _cids.length; i++) {
        RegistrationInfo memory regInfo = rightsToOwners[_cids[i]];

        for(uint8 j = 0; j < regInfo.owners.length; j++) {
          uint256 ownerShare = value.div(100).mul(regInfo.shares[j]);

          regInfo.owners[j].transfer(ownerShare);
        }
      }

      totalReceivedAmount.add(value);

      emit RightsPaymentReceived(msg.sender, value);

      // find range and token id
      uint256 tokenId;
      for(uint i = 0; i < tokenIds.length; i++) {
          uint256 id = tokenIds[i];
          if(value > priceRanges[id].min && value <= priceRanges[id].max) {
              tokenId = tokenIds[i];
              break;
          }
      }

      // calculate no. of tokens to be transferred
      uint256 tokenAmount = value.div(prices[tokenId]);
      // update token supply
      tokenSupply[tokenId].add(tokenAmount);
      // transfer token
      super.mint(msg.sender, tokenId, tokenAmount, '');
  }
}
