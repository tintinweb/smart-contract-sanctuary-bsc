// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import './interfaces/IL00TMeta.sol';
import './interfaces/IST0NEMeta.sol';
import './interfaces/IF0RGEBurn.sol';
import './interfaces/IElements.sol';

contract F0RGE {
  address private _owner;
  IL00TMeta private L00TMeta;
  IST0NEMeta private ST0NEMeta;
  IF0RGEBurn private L00T;
  IF0RGEBurn private ST0NE;
  IElements private Elements;

  constructor(
    address _elements,
    address _l00t,
    address _st0ne
  ){
    Elements = IElements(_elements);
    L00T = IF0RGEBurn(_l00t);
    ST0NE = IF0RGEBurn(_st0ne);
    L00TMeta = IL00TMeta(L00T.dataContract());
    ST0NEMeta = IST0NEMeta(ST0NE.dataContract());
    // temporary allow owner to do everything
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, 'F0RGE: caller is not the Owner');
    _;
  }

  // TODO: FINISH FORGE CONTRACT - TEMPORARY ALL ACCESS FOR TESTNET PURPOSES
  function getST0NELevels(uint256 tokenId) public view returns(uint8[2] memory){
    return ST0NEMeta.getProtoMeta(tokenId);
  }
  function getL00TLevels(uint256 tokenId) public view returns(uint8[8][2] memory){
    return L00TMeta.getUpgradeState(tokenId);
  }
  // we may want individual levels somtimes only
  function getL00TRefineLevels(uint256 tokenId) public view returns(uint8[8] memory){
    return L00TMeta.getUpgradeState(tokenId)[0];
  }
  function getL00TElementLevels(uint256 tokenId) public view returns(uint8[8] memory){
    return L00TMeta.getUpgradeState(tokenId)[1];
  }

  function refine(uint256 lootId1, uint256 lootId2, uint256 stoneId, uint8 slot) public {
    // refine logic
    // ...
    // refine success
    _refineSlot(lootId1, slot);
    // burn
    L00T.F0RGEBurn(lootId2);
    ST0NE.F0RGEBurn(stoneId);
  }

  function enchant(uint256 lootId1, uint256 lootId2, uint256 stoneId, uint8 slot) public {
    // enchant logic
    // ...
    // enchant success
    _enchantSlot(lootId1, slot, 1);
    // burn
    L00T.F0RGEBurn(lootId2);
    ST0NE.F0RGEBurn(stoneId);
  }

  function _refineSlot(uint256 tokenId, uint8 _slot) private {
    L00TMeta.refineSlot(tokenId, _slot);
  }
  function _enchantSlot(uint256 tokenId, uint8 _slot, uint8 _elem) private {
    L00TMeta.enchantSlot(tokenId, _slot, _elem);
  }
  
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '../interfaces/IElements.sol';

interface IL00TMeta {
    function getWeapon(uint256 tokenId) external view returns (string memory);

    function getChest(uint256 tokenId) external view returns (string memory);

    function getHead(uint256 tokenId) external view returns (string memory);

    function getWaist(uint256 tokenId) external view returns (string memory);

    function getFoot(uint256 tokenId) external view returns (string memory);

    function getHand(uint256 tokenId) external view returns (string memory);

    function getNeck(uint256 tokenId) external view returns (string memory);

    function getRing(uint256 tokenId) external view returns (string memory);

    function getMetaData(uint256 tokenId) external view returns (string memory);

    function mintCheck(uint256 tokenId) external;

    function getUpgradeState(uint256 tokenId)
        external
        view
        returns (uint8[8][2] memory);

    function setUpgradeState(
        uint256 tokenId,
        uint8[8][2] calldata _upgradeState
    ) external view returns (uint8[8][2] memory);

    function hasUpgrade(uint256 tokenId) external view returns (bool);

    function Recipes(uint8 elem1, uint8 elem2) external view returns (uint8);

    function refineSlot(uint256 tokenId, uint8 _slot) external;

    function enchantSlot(
        uint256 tokenId,
        uint8 _slot,
        uint8 _elem
    ) external;

    function setForge(address _forge) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '../interfaces/IElements.sol';

interface IST0NEMeta {
    function getStone(uint8 stone) external view returns (string memory);

    function getElement(uint8 stone, uint8 elem)
        external
        view
        returns (string memory);

    function getStoneFill(uint8 stone) external view returns (string memory);

    function getElemFill(uint8 elem) external view returns (string memory);

    function getProtoMeta(uint256 tokenId)
        external
        view
        returns (uint8[2] memory);

    function getMetaParts(uint256 tokenId)
        external
        view
        returns (string[6] memory);

    function getMetaData(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IF0RGEBurn {
    function F0RGEBurn(uint256 tokenId) external;
    function dataContract() external returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IElements {
    function getBG(uint256 tokenId) external view returns (string memory);

    function ElemStr(uint8 elem) external view returns (string memory);

    function getFC(uint8 idx) external view returns (string memory);
}