// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./ierc20.sol";
import "./safemath.sol";

contract VIVI is ierc20{
    using SafeMath for uint256;

    mapping (address => uint256) private m_balances;

    mapping (address => mapping (address => uint256)) private m_allowances;

    uint8 private m_decimals;
    string private m_name;
    string private m_symbol;    
    address public m_creator;
    uint256 public m_price;
    uint256 public m_gifts;
    uint256 public m_giftT;
    uint256 public m_mints;
    uint256 public m_mintT;
    uint256 private C_IntervalGift;
    uint256 private C_IntervalMint;
    uint256 private m_totalSupply;

    constructor() {
        m_name = "ViVi Yin";
        m_symbol = "VIVI";
        m_decimals = 18;
        m_totalSupply = 10000000 * 10 ** m_decimals;
        m_creator = msg.sender;
        m_balances[msg.sender] = m_totalSupply;
        m_price = 1 * (10 ** m_decimals) / 1000;
        
        C_IntervalGift = 24*60*60;
        C_IntervalMint = 365*24*60*60;

        _refreshGift();
        _refreshMint();

        emit Transfer(address(0), msg.sender, m_totalSupply);
    }

    function name() external view override returns (string memory){
        return m_name;
    }

    function symbol() external view override returns (string memory){
        return m_symbol;
    }

    function decimals() external view override returns (uint8){
        return m_decimals;
    }

    function totalSupply() external view override returns (uint256){
        return m_totalSupply;
    }

    function balanceOf(address _owner) external view override returns (uint256 balance){
        return m_balances[_owner];
    }

    function transfer(address _to, uint256 _value) external override returns (bool success){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool success){
        _approve(_from, msg.sender, m_allowances[_from][msg.sender].sub(_value));
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool success){
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256 remaining){
        return m_allowances[_owner][_spender];
    }

    function complimentary(string memory _str) external {
        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked("God bless vivi."))){
            if (block.timestamp > m_giftT.add(C_IntervalGift)){
                _refreshGift();
            }
            uint256 randGift = uint256(keccak256(abi.encodePacked(block.timestamp))).mod(100).add(1)*10**m_decimals;
            randGift = (randGift > m_gifts? m_gifts : randGift);
            m_gifts = m_gifts.sub(randGift);
            _transfer(m_creator, msg.sender, randGift);
        }
    }

    function mint() external payable {
        uint256 _amount = msg.value.div(m_price)*10**m_decimals;
        require(0 != _amount);
        if (block.timestamp > m_mintT.add(C_IntervalMint)){
            _refreshMint();
        }
        m_mints = m_mints.sub(_amount);
        m_balances[msg.sender] = m_balances[msg.sender].add(_amount);
        m_totalSupply = m_totalSupply.add(_amount);
    }

    function lottery() external {
        if (address(this).balance < 1*10**m_decimals){
            return;
        }
        uint256 _amount = m_balances[msg.sender];
        uint256 _payed = 0;
        _amount = _amount.mul(10000).div(m_totalSupply);
        if (0 == _amount){
            return;
        }
        _amount = (_amount > 100 ? 100 : _amount);
        if (uint256(keccak256(abi.encodePacked(block.timestamp))).mod(10000) < _amount){
            _payed = address(this).balance*9/10;
            payable(msg.sender).transfer(_payed);
            emit Payabled(msg.sender, _payed);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0));
        require(recipient != address(0));

        m_balances[sender] = m_balances[sender].sub(amount);
        m_balances[recipient] = m_balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0));
        require(spender != address(0));

        m_allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _refreshGift() internal{
        m_gifts = 100 * 10 ** m_decimals;
        m_giftT = block.timestamp;
    }

    function _refreshMint() internal{
        m_mints = m_totalSupply.mul(5).div(100);
        m_mintT = block.timestamp;
    }

    receive() external payable {
        uint256 _amount = msg.value.div(m_price)*10**m_decimals;
        if (0 != _amount){
            _transfer(m_creator, msg.sender, _amount);
        }
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        uint256 _amount = msg.value.div(m_price)*10**m_decimals;
        if (0 != _amount){
            _transfer(m_creator, msg.sender, _amount);
        }
        emit Fallbacked(msg.sender, msg.data);
    }

    event Received(address indexed _sender, uint256 _value);
    event Fallbacked(address indexed _sender, bytes _data);
    event Payabled(address indexed _receipt, uint256 _value);
}