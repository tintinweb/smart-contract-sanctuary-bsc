/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IBEP20 {
  
    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ORGXICO is Ownable {
    IBEP20 public token;
    IBEP20 public BUSD;
    uint256 public rate = 200000000000000000;
    uint256 public airdrop = 100;
    uint256 public rewards=5; 
    address[]  public _airaddress;
    bool private hasStart=false;
    uint256 public endDate=0;
    uint256 public totaldistribute=0;
    uint256 public no_of_distribute=0;
    constructor(){
        token = IBEP20(0x20e753aE4837C36d60e7d1C18dD7e878C923bA57);
        BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    } 
    function buyTokens(uint256 _amount) public  returns(bool){
        require(hasStart==true,"Sale is not started");
        require(block.timestamp<endDate,"ICO Completed"); 
        require(checkFundAllowed()>((_amount*(10**18))/rate), "ICO: Not Allowed by the Owner");
        require(BUSD.allowance(msg.sender,address(this))>_amount,"PLEASE ALLOW FUND FIRST");
        totaldistribute=totaldistribute+(((_amount*(10**18))/rate));
        require(no_of_distribute>=totaldistribute, "All Token Distributed");
        token.transferFrom(owner(), msg.sender, (((_amount*(10**18))/rate)));
        BUSD.transferFrom(msg.sender,owner(),_amount);
        return true;
    }    
    function startICO(uint256 _rate, uint256 _endDate, uint256 _no_of_distribute) public onlyOwner returns(bool){
        rate = _rate;
        endDate=_endDate;
        hasStart=true;
        totaldistribute=0;
        no_of_distribute=(_no_of_distribute*(10**18));
        return true;
    }
    function setDrop(uint256 _airdrop, uint256 _rewards) onlyOwner public returns(bool){
        
            airdrop = _airdrop;
            rewards = _rewards;
            delete _airaddress;
            
            return true;
    }
    function airdropTokens(address ref_address) public returns(bool){
        require(airdrop!=0, "No Airdrop started yet");
            bool _isExist = false;
            for (uint8 i=0; i < _airaddress.length; i++) {
                if(_airaddress[i]==msg.sender){
                    _isExist = true;
                }
            }
                require(_isExist==false, "Already Dropped");
                    token.transferFrom(owner(), msg.sender, airdrop*(10**18));
                    token.transferFrom(owner(), ref_address, ((airdrop*(10**18)*rewards)/100));
                    _airaddress.push(msg.sender);
                
    return true;
    }
    
    function checkFundAllowed() public view returns(uint256){
        return token.allowance(owner(),address(this));
    }
    
}