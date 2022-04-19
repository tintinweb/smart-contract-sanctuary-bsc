// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "IERC20.sol";
import "SafeERC20.sol";
import "Ownable.sol";
import "Pausable.sol";

contract coinAc is Ownable, Pausable {

    IERC20 private BUSD; //ERC-20 BUSD token declaration
    uint256 public coins; //coins counter, supported in busd tokens that te contract has
    address private _owner; //conytract owner with claim transaction permissions

    event CoinBought(
        address buyer,
        uint256 packType,
        uint date
    );

    event CoinClaimed(
        address claimer,
        uint256 packType,
        uint date
    );

    event NewVersionMigration(
        address newContract,
        uint256 busd,
        uint256 coins
    );


    //ENVIRONMENT VARIABLES
    //BUSD TESTNET TOKEN ADDRESS: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
    //TESTNET OWNER ADDRESS: 0xF8A28517ab8b859706ED70c8dc0F2f2D6c539B2A - JONITISO TESTNET WALLET
    //10 BUSD: ALLOWANCE : 10000000000000000000
    //THIS ACTUAL CONTRACT: 0x99d00cFB6c7fB101b8c2b8c71B8E330fcd2513Ba

    constructor(address _BUSD, address _theOwner, uint256 _coins) {
      BUSD = IERC20(_BUSD);
      _owner = _theOwner;
      coins = _coins;
    }

    //PAUSER AND UNPAUSER - EDIT
    function pause() public onlyOwner whenNotPaused{
        _pause();
    }

    function unpause() public onlyOwner whenPaused{
        _unpause();
    }


    //BUY PACKS
   //before that is necesary the user allowance to the contract address in WEB3 - 10000000000000000000; //10 BUSD
    function buyPackOne() public payable whenNotPaused{
        uint256 packType = 1;
        uint256 value =  10000000000000000000; //10 BUSD
        uint256 units = 100;
        require(IERC20(BUSD).balanceOf(msg.sender) >= value, "BUSD: Insufficient funds");  
        require(IERC20(BUSD).allowance(msg.sender, address(this)) >= value, "BUSD: Insufficient allowance funds");
        SafeERC20.safeTransferFrom(IERC20(BUSD), msg.sender, address(this), value);
        coins +=units;

        //event buy
        emit CoinBought(msg.sender, packType, block.timestamp);
    }

    //before that is necesary the user allowance to the contract address in WEB3 - 20000000000000000000; //20 BUSD
    function buyPackTwo() public payable whenNotPaused{
        uint256 packType = 2;
        uint256 precio =  20000000000000000000; //20 BUSD
        uint256 units = 200;
        require(IERC20(BUSD).balanceOf(msg.sender) >= precio, "BUSD: Insufficient funds");  
        require(IERC20(BUSD).allowance(msg.sender, address(this)) >= precio, "BUSD: Insufficient allowance funds");
        SafeERC20.safeTransferFrom(IERC20(BUSD), msg.sender, address(this), precio);
        coins +=units;

        //event buy
        emit CoinBought(msg.sender, packType, block.timestamp);
    }

    //before that is necesary the user allowance to the contract address in WEB3 - 30000000000000000000; //30 BUSD
    function buyPackThree() public payable whenNotPaused{
        uint256 packType = 3;
        uint256 value =  30000000000000000000; //30 BUSD
        uint256 units = 300;
        require(IERC20(BUSD).balanceOf(msg.sender) >= value, "BUSD: Insufficient funds");  
        require(IERC20(BUSD).allowance(msg.sender, address(this)) >= value, "BUSD: Insufficient allowance funds");
        SafeERC20.safeTransferFrom(IERC20(BUSD), msg.sender, address(this), value);
        coins +=units;

        //event buy
        emit CoinBought(msg.sender, packType, block.timestamp);
    }
    

    //CLAIM PACKS
    //before that, the fee payment to ACKA wallet should be ready - different value for each claim pack
    function claimPackOne(address _destinatary) public onlyOwner whenNotPaused{
        uint256 packType = 1;
        uint256 value =  10000000000000000000; //10 BUSD
        uint256 units = 100;
        require(IERC20(BUSD).balanceOf(address(this)) >= value, "BUSD: Contract insufficient funds");
        require(coins>= units, "COINS: Insufficient funds");
        IERC20(BUSD).transfer(_destinatary, value);
        coins -=units;

        //event claim
        emit CoinClaimed(msg.sender, packType, block.timestamp);
    }

    //before that, the fee payment to ACKA wallet should be ready - different value for each claim pack
    function claimPackTwo(address _destinatary) public onlyOwner whenNotPaused{
        uint256 packType = 2;
        uint256 value =  50000000000000000000; //50 BUSD
        uint256 units = 500;
        require(IERC20(BUSD).balanceOf(address(this)) >= value, "BUSD: Contract insufficient funds");
        require(coins>= units, "COINS: Insufficient funds");
        IERC20(BUSD).transfer(_destinatary, value);
        coins -=units;

        //event claim
        emit CoinClaimed(msg.sender, packType, block.timestamp);
    }

    //before that, the fee payment to ACKA wallet should be ready - different value for each claim pack
    function claimPackThree(address _destinatary) public onlyOwner whenNotPaused{
        uint256 packType = 3;
        uint256 value =  200000000000000000000; //200 BUSD
        uint256 units = 2000;
        require(IERC20(BUSD).balanceOf(address(this)) >= value, "BUSD: Contract insufficient funds");
        require(coins>= units, "COINS: Insufficient funds");
        IERC20(BUSD).transfer(_destinatary, value);
        coins -=units;

        //event claim
        emit CoinClaimed(msg.sender, packType, block.timestamp);
    }

    //before that, the fee payment to ACKA wallet should be ready - different value for each claim pack
    function claimPackFour(address _destinatary) public onlyOwner whenNotPaused{
        uint256 packType = 4;
        uint256 value =  500000000000000000000; //500 BUSD
        uint256 units = 5000;
        require(IERC20(BUSD).balanceOf(address(this)) >= value, "BUSD: Contract insufficient funds");
        require(coins>= units, "COINS: Insufficient funds");
        IERC20(BUSD).transfer(_destinatary, value);
        coins -=units;

        //event claim
        emit CoinClaimed(msg.sender, packType, block.timestamp);
    }

    //export BUSD and coins for next contract version
    function exportFundsVersion(address _destinatary) public onlyOwner whenNotPaused{
        require(IERC20(BUSD).balanceOf(address(this)) > 0, "There aren't BUSD tokens to export");
        require(IERC20(BUSD).balanceOf(address(this))/1000000000000000000 == coins/10, "The BUSD tokens and unity coins doesn't match"); //compare equivalence
        uint256 tokens = IERC20(BUSD).balanceOf(address(this));
        IERC20(BUSD).transfer(_destinatary, tokens);

         //event - migration
        emit NewVersionMigration(_destinatary, tokens/1000000000000000000, coins);
    }


}