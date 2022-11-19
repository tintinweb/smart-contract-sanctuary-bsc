//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface IPart {
    function reduceLifetime(address _requestor, uint256 _tokenId, bytes32 _repairType ) external;
    
    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function checkIsApprovedOrOwner(address spender, uint256 tokenId) view external returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./interfaces/IPart.sol";
contract Repair {

  function repairPart(address _contract, uint256 _tokenId, bytes32 _repairType) public {

    // check current ownership
    IPart part = IPart(_contract);
    require(
        part.checkIsApprovedOrOwner(address(this), _tokenId),
        "Part: requestor is not owner of this part"
    );
    address partOwner = part.ownerOf(_tokenId);
    IPart(_contract).reduceLifetime(partOwner, _tokenId, _repairType);
  }
}