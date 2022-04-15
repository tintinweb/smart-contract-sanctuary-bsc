/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// File: tranferToken.sol


pragma solidity ^0.8.0;

//Title Simeta Presale
//Author Sccot from Simeta

interface IERC20 {

 
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


//Authorization
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//Withdraw
contract transferToken is Ownable {

    address private myWallet;

    constructor() {
        myWallet = 0xe627f0393e8EbFa1aE6973Ec8847736d81030eaD;
    }

     
    //Transfer
    function rescueToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(myWallet, _amount);
    }

    //Withdraw
    function rescueETH(uint256 _amount) external onlyOwner {
        payable(myWallet).transfer(_amount);
    }

   
    //to recieve BNB from presale
    receive() external payable {
        require(msg.value >= 0.2 ether && msg.value <=20 ether, "error value, 0.2 - 20 BNB is accepted");
    }

}