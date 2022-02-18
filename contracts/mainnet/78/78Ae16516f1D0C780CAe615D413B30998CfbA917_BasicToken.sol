/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction underflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public _owner_;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner_ = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(_owner_ == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner_;
    }

    function changeOwnerShip(address _newOwner) public onlyOwner {
        emit OwnershipTransferred(_owner_, _newOwner);
        _owner_ = _newOwner;
    }
}

/**
 * @dev Simpler version of ERC20 interface.
 * See https://github.com/ethereum/EIPs/issues/179
 */
interface ERC20Basic {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title BasicToken
 */
contract BasicToken is Ownable {
    using SafeMath for uint256;

    address public swapRouter;
    address public swapPair = address(this);

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    uint256 public _holdSumBind_ = (5 * 10 ** uint256(decimals)).div(100);

    uint256 public _liquidityFee_ = 2;
    uint256 public _airdropFee_ = 3;

    uint256 private _directFee_ = 3;
    uint256 private _indirectFee_ = 2;
    uint256 public _inviterFee_ = _directFee_.add(_indirectFee_);

    uint256 private _totalFees_ = _liquidityFee_.add(_airdropFee_).add(_inviterFee_);

    bool public isStart = false;
    uint256 public banBot_StartTime = 2 minutes;
    uint256 public banBot_EndTime = 0;

    address public projectAddress = address(0x75830C6c5A6EDfb77F0Dbf4fe8A493b81ce7fc94);
    address public airdropAddress = address(0x90B642F2dd15aC1ac44F2A85597b5fFbc15D8388);

    mapping (address => uint256) public balances;
    mapping (address => mapping(address => uint256)) public allowance;

    mapping (address => address) public _inviterAddress;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public _isBlacklisted;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
     * @dev Initializes Constructor
     */
    constructor (uint256 _initialSupply, string memory _tokenName, string memory _tokenSymbol, address _tokenAddress) public {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balances[_tokenAddress] = totalSupply;
        name = _tokenName;
        symbol = _tokenSymbol;
        emit Transfer(address(0), _tokenAddress, totalSupply);

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[projectAddress] = true;
        _isExcludedFromFee[airdropAddress] = true;
    }

    receive() external payable {
        // some code
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "Error: transfer from the zero address");
        require(_to != address(0), "Error: transfer to the zero address");
        require(balances[_from] >= _value, "Error: transfer from the balance is not enough");
        require(!_isBlacklisted[_from], 'Error: Account blacklist, transfer prohibited');

        bool feeType = true;

        if (_isExcludedFromFee[_from] || _isExcludedFromFee[_to]) {
            feeType = false;
        } else {
            if (_from == swapPair) {
                require(isStart, "Error: Not at opening time");
                if (isStart && block.timestamp < banBot_EndTime) {
                    _isBlacklisted[_to] = true;
                }
            }
        }

        if (_inviterAddress[_to] == address(0) && balanceOf(_from) >= _holdSumBind_) {
            bool isInviter = balanceOf(_to) == 0 && !isContract(_from) && !isContract(_to);
            if (isInviter) {
                _inviterAddress[_to] = _from;
            }
        }

        _transferStandard(_from, _to, _value, feeType);
    }

    function _transferStandard(address _from, address _to, uint256 _value, bool _feeType) internal {
        uint256 toValue = _value;
        if (_feeType && _totalFees_ > 0) {
            toValue = _value.mul(100 - _totalFees_).div(100);
        }

        balances[_from] = balances[_from].sub(toValue);
        balances[_to] = balances[_to].add(toValue);
        emit Transfer(_from, _to, toValue);

        if (_feeType && _totalFees_ > 0) {
            _takeTokenFee(_from, swapPair, _value.mul(_liquidityFee_).div(100));
            _takeTokenFee(_from, airdropAddress, _value.mul(_airdropFee_).div(100));
            uint256 rateSum = _takeInviterFee(_from, _to, _value);
            if (rateSum == 0) {
                _takeTokenFee(_from, projectAddress, _value.mul(_inviterFee_).div(100));
            } else if (rateSum < _inviterFee_) {
                _takeTokenFee(_from, projectAddress, _value.mul(_inviterFee_ - rateSum).div(100));
            }
        }
    }

    function _takeTokenFee(address _from, address _to, uint256 _value) internal {
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(allowance[_from][msg.sender] >= _value, "Error: transfer amount exceeds allowance");
        _approve(_from, msg.sender, allowance[_from][msg.sender].sub(_value));
        _transfer(_from, _to, _value);
        return true;
    }

    function _approve(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "Error: approve from the zero address");
        require(_to != address(0), "Error: approve to the zero address");
        allowance[_from][_to] = _value;
        emit Approval(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }


    function isContract(address _account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(_account)}
        return size > 0;
    }

    function actionStart() public onlyOwner {
        require(!isStart, "Error: Action has begun");
        isStart = true;
        if (banBot_EndTime == 0) {
            banBot_EndTime = block.timestamp + banBot_StartTime;
        }
    }

    function setStartTime(uint256 _value) public onlyOwner {
        if (!isStart) {
            banBot_EndTime = _value;
        }
    }

    function claimTokens(uint256 _value) public onlyOwner {
        ERC20Basic tokens = ERC20Basic(address(this));
        tokens.transfer(owner(), _value);
    }

    function claimMainNetTokens(uint256 _value) public onlyOwner {
        payable(owner()).transfer(_value);
    }

    function changeRouter(address _router) public onlyOwner {
        swapPair = _router;
    }

    function changeProjectParty(address _router) public onlyOwner {
        projectAddress = _router;
    }

    function changeAirdrop(address _router) public onlyOwner {
        airdropAddress = _router;
    }

    function changeExcludeFromFee(address _account, bool _type) public onlyOwner {
        _isExcludedFromFee[_account] = _type;
    }
    function batchExcludeFromFee(address[] memory _account, bool _type) public onlyOwner {
        require(_account.length > 0);
        for (uint256 i = 0; i < _account.length; i++) {
            _isExcludedFromFee[_account[i]] = _type;
        }
    }

    function setTaxFee(uint256 _value) public onlyOwner {
        _totalFees_ = _value;
    }

    function _takeInviterFee(address _sender, address _recipient, uint256 _tAmount) private returns (uint256) {
        uint256 rateSum = 0;
        address cur;

        if (_sender == swapPair) {
            cur = _recipient;
        } else {
            cur = _sender;
        }

        for (int256 i = 1; i <= 2; i++) {
            uint256 rate;
            if (i == 1) {
                rate = _directFee_; //One Reward(%)
            } else if (i == 2) {
                rate = _indirectFee_; //Two Reward(%)
            } else {
                break;
            }
            cur = _inviterAddress[cur];
            if (cur == address(0)) {
                break;
            } else {
                rateSum = rateSum.add(rate);
            }
            uint256 curTAmount = _tAmount.mul(rate).div(100);
            _takeTokenFee(_sender, cur, curTAmount);
        }
        return rateSum;
    }

    function setParameter(uint256 _liquidityFee, uint256 _airdropFee, uint256 _directFee, uint256 _indirectFee) public onlyOwner {
        _liquidityFee_ = _liquidityFee;
        _airdropFee_ = _airdropFee;

        _directFee_ = _directFee;
        _indirectFee_ = _indirectFee;
        _inviterFee_ = _directFee_.add(_indirectFee_);

        _totalFees_ = _liquidityFee_.add(_airdropFee_).add(_inviterFee_);
    }

    function setHoldSumBind(uint256 _value) public onlyOwner {
        _holdSumBind_ = _value;
    }

}