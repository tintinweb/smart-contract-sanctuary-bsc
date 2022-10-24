/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWithdrawContract{
    struct RechargeData{
        uint256 rechargeNum;
        bool _isExists;
    }

    struct WithdrawData{
        uint256 WithdrawNum;
        bool _isExists;
    }

    event OwnershipTransferred(address indexed oldOwner,address indexed newOwner);
    event WithdrawLog( address indexed _address,IERC20 _token, uint256 _amount );

    function transferOwnership(address account_) external returns(bool);
    function addBlackUser(address _address) external returns(bool);
    function removeBlackUser(address _address) external returns(bool);
    function withdrawToken(IERC20 __token, uint256 __amount) external returns( bool );
    function withdrawToUser( address _spender,uint256 _amount) external returns( bool );
    function getWithdrawList() external view returns(address[] memory res_wallets, uint256[] memory withdrawLists);
    function getBNBBalances(address[] calldata wallets) external view returns (address[] memory res_wallets, uint256[] memory bnb_balances);
    function getTokenBalances(address[] calldata wallets,IERC20 token) external view returns (address[] memory res_wallets,uint256[] memory token_balances);
    function setPayToken(IERC20 _payToken) external returns(bool);
    function getLastBlockNumber() external view returns(uint256);
}

contract WithdrawContract is IWithdrawContract{

    address public _owner;
    IERC20 public payToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
    mapping (address => bool) public isBlacklist;
    mapping(address => WithdrawData) public _WithdrawMap;

    address[] private _WithdrawArr;

    constructor(){
        _owner = msg.sender;
    }



    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier notInBlack(address _spender){
        require( !isBlacklist[_spender], "in blacklist");
        _;
    }

    function transferOwnership(address account_) 
        external 
        onlyOwner
        returns(bool)
    {
        emit OwnershipTransferred(_owner, account_);
        _owner = account_;
        return true;
    }

    function setPayToken(IERC20 _payToken)
        external
        onlyOwner
        returns(bool)
    {
        payToken = _payToken;
        return true;
    }

    function addBlackUser(address _address)
        external
        onlyOwner
        returns(bool)
    {
        if( !isBlacklist[_address] ){
            isBlacklist[_address] = true;
        }
        return true;
    }

    function removeBlackUser(address _address)
        external
        onlyOwner
        returns(bool)
    {
        if( isBlacklist[_address] ){
            isBlacklist[_address] = false;
        }
        return true;
    }


    function withdrawToken(IERC20 __token, uint256 __amount)
        external
        onlyOwner
        returns( bool )
    {
        IERC20 token = IERC20(__token);
        token.transfer(msg.sender, __amount);
        return true;
    }

    function withdrawToUser( address _spender,uint256 _amount)
        external
        onlyOwner
        notInBlack(_spender)
        returns( bool )
    {
        IERC20 token = IERC20(payToken);
        token.transfer(_spender, _amount);
        emit WithdrawLog( _spender, token, _amount );
        if( _WithdrawMap[_spender]._isExists ){
            _WithdrawMap[_spender].WithdrawNum += _amount;
        }else{
            _WithdrawMap[_spender]._isExists = true;
            _WithdrawMap[_spender].WithdrawNum = _amount;
            _WithdrawArr.push( _spender );
        }
        return true;
    }


    function getWithdrawList()
        external
        view
        onlyOwner
        returns(
            address[] memory res_wallets,
            uint256[] memory withdrawLists
        )
    {
        for( uint256 index = uint256(0); index <  _WithdrawArr.length; index ++ ){
            res_wallets[index] = _WithdrawArr[index];
            withdrawLists[index] = _WithdrawMap[ _WithdrawArr[index] ].WithdrawNum;
        }
    }

    function getBNBBalances(address[] calldata wallets)
        external
        view
        returns (
            address[] memory res_wallets,
            uint256[] memory bnb_balances
        )
    {
        res_wallets = new address[](wallets.length);
        bnb_balances = new uint256[](wallets.length);
        for (uint256 i = 0; i < wallets.length; i++) {
            res_wallets[i] = wallets[i];
            bnb_balances[i] = wallets[i].balance;
        }
    }

    function getTokenBalances(address[] calldata wallets,IERC20 token)
        external
        view
        returns (
            address[] memory res_wallets,
            uint256[] memory token_balances
        )
    {
        res_wallets = new address[](wallets.length);
        token_balances = new uint256[](wallets.length);
        for (uint256 i = 0; i < wallets.length; i++) {
            res_wallets[i] = wallets[i];
            token_balances[i] = IERC20(token).balanceOf(wallets[i]);
        }
    }

    function getLastBlockNumber()
        external
        view
        returns(uint256)
    {
        return block.number;
    }

}