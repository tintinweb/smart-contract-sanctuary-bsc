//     ___                         __ 
//    /   |  _____________  ____  / /_
//   / /| | / ___/ ___/ _ \/ __ \/ __/
//  / ___ |(__  |__  )  __/ / / / /_  
// /_/  |_/____/____/\___/_/ /_/\__/  
// 
// 2022 - Assent Protocol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./IERC20.sol";
import "./Ownable.sol";

interface IASNT {
    function mint(address to, uint256 amount) external;
    function maxSupply() view external returns (uint256);
}

contract AssentBondManager is Ownable {

    event RewardsMinted( address indexed caller, address indexed recipient, uint amount );
    event ASNTMaxSupplyReached( address indexed recipient, uint amount );
    event TokenAdded(uint256 amount);

	// ASNT token
    IASNT immutable public ASNT;

    uint256 public tokenAvailableForBonds;
    uint256 public totalMintedForBonds;
    mapping( address => bool ) public isBond;

    constructor (
        IASNT _ASNT
    ) {
        ASNT = _ASNT;
    }

    function mintRewards( address _recipient, uint _amount ) external returns ( bool ) {
        require( isBond[ msg.sender ], "Not approved" );
        require( tokenAvailableForBonds >= _amount, "Not enough token available for bonds" );
        return _checkBeforeMintRewards( _recipient, _amount );
    } 

    function addTokenForBonds(uint256 _amount) public onlyOwner {
        tokenAvailableForBonds += _amount;        
        emit TokenAdded(_amount);
    }

    function getMaxRewardsAvailableForBonds() view external returns (uint256) {
        return tokenAvailableForBonds;
    }  

    // Check if a mint is possible
    function _checkBeforeMintRewards(address _recipient, uint _amount ) internal returns ( bool ) {
        // Mint only if max supply not reached
        uint256 _totalSupply = IERC20(address(ASNT)).totalSupply();
        uint256 _maxCapSupply = ASNT.maxSupply();

        if ((_totalSupply + _amount) <= _maxCapSupply) {
            ASNT.mint(_recipient, _amount);
            tokenAvailableForBonds -= _amount;
            totalMintedForBonds += _amount; 
            emit RewardsMinted(msg.sender, _recipient, _amount);
            return true;
        }
        else {
            emit ASNTMaxSupplyReached(_recipient, _amount);       
            return false;
        }
    }

    function setNewBond(address _address, bool _statut) external onlyOwner {
        require(_address != address(0), "setNewBond: ZERO");
        isBond[ _address ] = _statut;
    }    

}