/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract transferCake is Ownable{

    IBEP20 public Cake;

    uint256 public BusinessFee = 990;
    uint256 public SupportFee = 10;
    address public BusinessWallet = 0x129e510A1dbffaf64C1f039296d077C6E7A14300;
    address public SupportWallet = 0x790c705B8b3143152A8c6CF77eCb6AFd839c3404;

    event CakeDeposti(address indexed user, uint256 depositAmount);
    event UpdateFeePercentage(address indexed owner, uint256 businessFee, uint256 supportFe);
    event FailSafe(address indexed token, address to, uint256 amount);
    event SetBusinessWallet(address indexed owner, address businessWallet);
    event SetSupportWallet(address indexed owner, address supportWallet);
    
    constructor(IBEP20 _Cake){
        Cake = _Cake;
    }
    
    function setBusinessWallet(address _BusinessWallet)external onlyOwner {
        require(_BusinessWallet!= address(0x0),"Recharge :: zero address dected");
        BusinessWallet = _BusinessWallet;
        emit SetBusinessWallet(msg.sender, _BusinessWallet);
    }
    
    function setSupportWallet(address _SupportWallet)external onlyOwner {
        require(_SupportWallet!= address(0x0),"Recharge :: zero address dected");
        SupportWallet = _SupportWallet;
        emit SetSupportWallet(msg.sender, _SupportWallet);
    }

    function updateCakeToken( address _newCake) external onlyOwner {
        require(address(0x0) != address(_newCake),"Recharge :: zero address dected");
        Cake = IBEP20(_newCake);
    }
    
    function exchange(uint256 _amount)external {
        require(_amount > 0,"Recharge :: Deposit number of tokens");
        uint256 tokens = _amount * (SupportFee) / (1e3);
        Cake.transferFrom(msg.sender, BusinessWallet, _amount - (tokens));
        Cake.transferFrom(msg.sender, SupportWallet, tokens);
        emit CakeDeposti(msg.sender, _amount);
    }
    
    function setRewardPercentage(uint256 _BusinessFee, uint256 _SupportFee)external onlyOwner {
        require(_BusinessFee + (_SupportFee) == 1000,"Invalid ");
        BusinessFee = _BusinessFee;
        SupportFee = _SupportFee;
        emit UpdateFeePercentage(msg.sender, _BusinessFee, _SupportFee);
    }
    
    function failSafe(address _token,address _to, uint256 _amount)external onlyOwner {
        
        if(_token == address(0x0)){
            payable(msg.sender).transfer(address(this).balance);
            emit FailSafe(address(this), _to, address(this).balance);
        }
        else {
            IBEP20(_token).transfer(_to, _amount);
            emit FailSafe(_token, _to, _amount);
        }
    }
}