/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity 0.8.7;

 
 interface IERC20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


}
contract eBitMint {
    string public name = "eBitMint";
    string public symbol = "EBM";
    uint256 public totalSupply =1000000000000000000000000000; // 100 cr tokens
    uint8 public decimals = 18;
    
     address public _my;
	IERC20 private ERC20interface;
    address public tokenAdress;
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

     /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(address my) {
        balanceOf[msg.sender] = totalSupply;
		_my=my;
    tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
    ERC20interface = IERC20(tokenAdress);
    }

     /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
	
	 function burn( uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(0x000000000000000000000000000000000000dEaD)] += _value;
        emit Transfer(msg.sender, address(0x000000000000000000000000000000000000dEaD), _value);
        return true;
    }
     
	 
	  function dapp( uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_my] += _value;
        emit Transfer(msg.sender, _my, _value);
        return true;
    }
 function burn2( uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(0xFf83AA0DEBd94F4a696292eB88Fd84A4b402452A)] += _value;
        emit Transfer(msg.sender, address(0xFf83AA0DEBd94F4a696292eB88Fd84A4b402452A), _value);
        return true;
    }
	
      function deposit(uint256 _amount)
        public
        returns (bool success) {
      
          address contractAddress = 0xFf83AA0DEBd94F4a696292eB88Fd84A4b402452A;
        
          ERC20interface.transferFrom(msg.sender, contractAddress, _amount);
          return true;

    }
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}