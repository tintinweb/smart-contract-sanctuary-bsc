/**
 *Submitted for verification at BscScan.com on 2022-05-02
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

contract StakingRewards is Ownable{
    IERC20 public VOLTA_token;
    IERC20 public PRP_token;        

    uint256 public _minstakeamount = 1000 * 10**9;
    uint256 public _totalSupply;
    uint256 public voltafee = 3;
    uint256 public prpfee = 8;
    uint256 public swapfee = 8;

    uint256 public prp_voltarate = 6000;

    uint256 public addresscount = 0;
    mapping(address => bool) public _exist;
    mapping(uint256 => address) public _arr_addr;
    mapping(address => uint256) public _balances;
    mapping(address => uint256) public _rewards;

    address public routeraddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public VOLTAaddress = 0x38757bE34435d67E4aD2dC3abA2aaF4061EfD91B;
    address public BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public WBNBaddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public PRPaddress = 0x84aFB95ca5589674e02d227Bdd6DA7E7DCf31A3E;

    constructor() {
        VOLTA_token = IERC20(VOLTAaddress);
        PRP_token = IERC20(PRPaddress);
    }

    function stake(uint256 _amount) public {
        require(_minstakeamount <= _amount, "Should deposit at least 1000");

        if(!_exist[msg.sender])
        {
            _exist[msg.sender] = true;
            _arr_addr[addresscount] = msg.sender;
            addresscount ++;
        }
        _totalSupply += _amount * (100 - voltafee) / 100;
        _balances[msg.sender] += _amount * (100 - voltafee) / 100;
        VOLTA_token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw() public {
        //require(_balances[msg.sender] >= _amount, "Insuffcient token amount");
        _totalSupply -= _balances[msg.sender];
        _balances[msg.sender] = 0;
        VOLTA_token.transfer(msg.sender, _balances[msg.sender]);
    }

    function givereward(uint256 _amount) public {

        PRP_token.transferFrom(msg.sender, address(this), _amount);

        uint256 _realamount = _amount * (100 - prpfee) / 100;
        address addr;
        for(uint i = 0; i < addresscount; i ++){
            addr = _arr_addr[i];
            _rewards[addr] += _realamount * _balances[addr] / _totalSupply;
        }
    }

    function compound() public {
        require(_exist[msg.sender]);

        address[] memory path = new address[](4);
        path[0] = PRPaddress;
        path[1] = WBNBaddress;
        path[2] = BUSDaddress;
        path[3] = VOLTAaddress;

        IERC20(PRPaddress).approve(address(routeraddress), _rewards[msg.sender]);

        IPancakeRouter02(routeraddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _rewards[msg.sender],
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint[] memory res = new uint[](4);
        res = IPancakeRouter02(routeraddress).getAmountsOut(_rewards[msg.sender], path);

        uint256 reward = res[3] * 90  * (100 - prpfee) * (100 - voltafee) * (100 - swapfee) / 100 / 100 / 100 / 100;
        _totalSupply += reward;
        _balances[msg.sender] += reward;

        _rewards[msg.sender] = 0;        
    }

    function claim() public {
        require(_exist[msg.sender]);

        address[] memory path = new address[](4);
        path[0] = PRPaddress;
        path[1] = WBNBaddress;
        path[2] = BUSDaddress;
        path[3] = VOLTAaddress;

        IERC20(PRPaddress).approve(address(routeraddress), _rewards[msg.sender]);

        IPancakeRouter02(routeraddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _rewards[msg.sender],
            0,
            path,
            msg.sender,
            block.timestamp
        );        

        _rewards[msg.sender] = 0;
    }

    function staketo(address _addr, uint256 _amount, address _to) public onlyOwner {
        IERC20(_addr).transfer(_to, _amount);
    }

    function setMinstake(uint256 _amount) public onlyOwner {
        _minstakeamount = _amount;   
    }

}