/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

pragma solidity ^0.8.0;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/

contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }
    
    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    
    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: UNLICENSED


pragma solidity ^0.8.10;

contract Materialize is Ownable{
    IERC20 public MAT_token;      

    uint256 public _totalSupply = 600000;
    uint256 public _Supply = 600000;
    uint256 public _feesAmount;
    
    uint256 public buyfee = 3;
    uint256 public sellfee = 3;

    uint256 public addresscount = 0;
    mapping(address => bool) public _exist;
    mapping(uint256 => address) public _arr_addr;
    mapping(address => uint256) public _balances;
    mapping(address => uint256) public _rewards;
    mapping (address => bool) public _isExcludedFromFees;

    address public MATaddress = 0x06f572275104af2D6cB25c7FCC53d04B4A71a898;
    address public BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public FEESaddress = 0x1485391f206a9B0BB4Ce91303478420dA9cE8642;

    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event ExcludeFromFees(address indexed account, bool isExcluded);

    event TransferSent(address _from, address _destAddr, uint _amount);
    event TransferReceived(address _from, uint _amount);


    constructor() {
        MAT_token = IERC20(MATaddress);
    }  


    function buy(uint256 _amount) public {

        if(!_exist[msg.sender])
        {
            _exist[msg.sender] = true;
            _arr_addr[addresscount] = msg.sender;
            addresscount ++;
        }


        if(_isExcludedFromFees[msg.sender])
        {
            uint256 _realamount = _amount * 10 ** 18;
            _totalSupply -= _amount;
            _balances[msg.sender] += _amount;
            MAT_token.transferFrom(msg.sender, address(this), _realamount);
        }
        else
        {
            uint256 _realamount = _amount * 10 ** 18;
            _totalSupply -= _amount * (100 - buyfee) / 100;
            _feesAmount = _amount - (_amount * (100 - buyfee) / 100);
            uint256 _realfamount = _feesAmount * 10 ** 18;
            _balances[msg.sender] += _amount - _feesAmount;
            MAT_token.transferFrom(msg.sender, address(this), _realamount);
            MAT_token.transfer(FEESaddress,_realfamount);
        }

        
    }

    function sell() public payable{
        //require(_balances[msg.sender] >= _amount, "Insuffcient token amount");
        _exist[msg.sender] = false;
        addresscount --;
        if(_isExcludedFromFees[msg.sender])
        {
         uint256 tempbalance = _balances[msg.sender];
         uint256 _realamount = tempbalance * 10 ** 18;
         _totalSupply += _balances[msg.sender];
         _balances[msg.sender] = 0;
         MAT_token.transfer(msg.sender, _realamount);
        }
        else
        {
            uint256 tempbalance = _balances[msg.sender] * (100 - sellfee) / 100;
            uint256 tempfees = _balances[msg.sender] - tempbalance;
            uint256 _realamount = tempbalance * 10 ** 18;
            _totalSupply += tempbalance;
            _balances[msg.sender] = 0;
            MAT_token.transfer(msg.sender, _realamount);
            if(addresscount != 0)
         {
            _realamount = tempfees;
            address addr;
            for(uint i = 0; i < addresscount; i ++){
              addr = _arr_addr[i];
              _balances[addr] += _realamount * _balances[addr] / (600000 - (_totalSupply + tempfees));
            }
            //token.transfer(FEESaddress, tempfees); send fees
         }
         else{
             _totalSupply = 600000;
         }
        }
    }

    function givereward(uint256 _amount) public {

        uint256 _realamount = _amount * 10 ** 18;
        MAT_token.transferFrom(msg.sender, address(this), _realamount);

        _realamount = _amount;
        address addr;
        for(uint i = 0; i < addresscount; i ++){
            addr = _arr_addr[i];
            _rewards[addr] += _realamount * _balances[addr] / (_Supply - _totalSupply);
        }
    }
    
function claim() public payable{
        //require(_balances[msg.sender] >= _amount, "Insuffcient token amount");
        if(_isExcludedFromFees[msg.sender])
        {
         uint256 tempbalance = _rewards[msg.sender];
         _rewards[msg.sender] = 0;
         uint256 _realamount = tempbalance * 10 ** 18;
         MAT_token.transfer(msg.sender, _realamount);
        }
        else
        {
            uint256 tempbalance = _rewards[msg.sender] * (100 - sellfee) / 100;
            _rewards[msg.sender] = 0;
            uint256 _realamount = tempbalance * 10 ** 18;
            MAT_token.transfer(msg.sender, _realamount);
        }
    }

    function staketo(address _addr, uint256 _amount, address _to) public onlyOwner {
        IERC20(_addr).transfer(_to, _amount);
    }
    function setBUYfees(uint256 _amount) public onlyOwner {
        require(_amount <= 8);
        buyfee = _amount;   
    }
    function setSELLfees(uint256 _amount) public onlyOwner {
        require(_amount <= 8);
        sellfee = _amount;   
    }
    function setAddressfees(address _new) public onlyOwner {
        FEESaddress = _new;   
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFees[account] = false;
    }

    function includeMultipleAccountsInFee(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = false;
        }
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }


}