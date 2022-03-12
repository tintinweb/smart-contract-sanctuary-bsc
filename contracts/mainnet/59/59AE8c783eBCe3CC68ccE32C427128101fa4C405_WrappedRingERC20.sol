// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import "./IRing.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Address.sol";
import "./ERC20.sol";
import "./Ownable.sol";

contract WrappedRingERC20 is ERC20, Ownable {
    using SafeERC20 for ERC20;
    using Address for address;
    using SafeMath for uint256;

    address public immutable RING;
    bool public live;

    // Fees section
    mapping(address => bool) public _pairWithFee;
    mapping(address => bool) public _isFeeExempt;
    uint256 public liquidityFee = 40;
    uint256 public treasuryFee = 25;
    uint256 public ringRiskFreeFundFee = 50;
    uint256 public sellFee = 20;
    uint256 public supplyControlFee = 25;
    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(ringRiskFreeFundFee).add(
            supplyControlFee
        );
    uint256 public feeDenominator = 1000;

    // System addresses section
    address public autoLiquidityFund;
    address public treasuryFund;
    address public ringRiskFreeFund;
    address public supplyControl;

    constructor(address _RING) ERC20("Wrapped RING", "wRING", 18) Ownable() {
        require(_RING != address(0));
        RING = _RING;
        live = false;

        _isFeeExempt[msg.sender] = true;

        autoLiquidityFund = 0xDD3AF8892E54C0cf7F01A062Eb6B54c3183D53c7;
        treasuryFund = 0x35D827D2467004EA3EE0528252c355867cA76739;
        ringRiskFreeFund = 0xc477463E356A2b638c3Ca17fdaC0F1838c301B3d;
        supplyControl = 0x85f9AcbE21cb7E016B1FeEfcdF29603F9Cc95c48;
    }

    /**
        @notice wrap RING
        @param _amount uint
        @return uint
     */
    function wrap(uint256 _amount) external returns (uint256) {
        require(live == true, "wRING: wrapping disabled");

        IERC20(RING).transferFrom(msg.sender, address(this), _amount);

        uint256 value = RINGTowRING(_amount);
        _mint(msg.sender, value);
        return value;
    }

    /**
        @notice unwrap RING
        @param _amount uint
        @return uint
     */
    function unwrap(uint256 _amount) external returns (uint256) {
        require(live == true, "wRING: unwrapping disabled");

        _burn(msg.sender, _amount);

        uint256 value = wRINGToRING(_amount);
        IERC20(RING).transfer(msg.sender, value);
        return value;
    }

    /**
        @notice converts wRING amount to RING
        @param _amount uint
        @return uint
     */
    function wRINGToRING(uint256 _amount) public view returns (uint256) {
        return _amount.mul(IRING(RING).index()).div(10**decimals());
    }

    /**
        @notice converts RING amount to wRING
        @param _amount uint
        @return uint
     */
    function RINGTowRING(uint256 _amount) public view returns (uint256) {
        return _amount.mul(10**decimals()).div(IRING(RING).index());
    }

    /**
        @notice only take fee if on _pairWithFee mapping
        @param from address
        @param to address
        @return bool
     */
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (_pairWithFee[from] || _pairWithFee[to]) && !_isFeeExempt[from];
    }

    /**
        @notice transfer ERC20 override
        @param to address
        @param value uint256
        @return bool
     */
    function transfer(address to, uint256 value) public override returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    /**
        @notice transferFrom ERC20 override
        @param from address
        @param to address
        @param value uint256
        @return bool
     */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (_allowances[from][msg.sender] != uint256(-1)) {
            _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value, "wRING: insufficient allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    /**
        @notice transferFrom main function
        @param sender address
        @param recipient address
        @param amount uint256
        @return bool
     */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(recipient, amount)
            : amount;

        _balances[sender] = _balances[sender].sub(amountReceived, "wRING: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    /**
        @notice take fee from _transferFrom function
        @param recipient address
        @param amount uint256
        @return bool
     */
    function takeFee(address recipient, uint256 amount) internal returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;

        if (_pairWithFee[recipient]) {
            _totalFee = totalFee.add(sellFee);
            _treasuryFee = treasuryFee.add(sellFee);
        }

        uint256 feeAmount = amount.div(feeDenominator).mul(_totalFee);
        _balances[autoLiquidityFund] = _balances[autoLiquidityFund].add(amount.div(feeDenominator).mul(liquidityFee));
        _balances[treasuryFund] = _balances[treasuryFund].add(amount.div(feeDenominator).mul(treasuryFee));
        _balances[ringRiskFreeFund] = _balances[ringRiskFreeFund].add(amount.div(feeDenominator).mul(ringRiskFreeFundFee));
        _balances[supplyControl] = _balances[supplyControl].add(amount.div(feeDenominator).mul(supplyControlFee));

        return amount.sub(feeAmount);
    }

    /**
        @notice set live status
        @param _live bool
     */
    function setLiveStatus(bool _live) public onlyOwner {
        live = _live;
    }

    /**
        @notice set new fee receivers
        @param _autoLiquidityFund address
        @param _treasuryFund address
        @param _ringRiskFreeFund address
        @param _supplyControl address
     */
    function setFeeReceivers(address _autoLiquidityFund, address _treasuryFund, address _ringRiskFreeFund, address _supplyControl) public onlyOwner {
        autoLiquidityFund = _autoLiquidityFund;
        treasuryFund = _treasuryFund;
        ringRiskFreeFund = _ringRiskFreeFund;
        supplyControl = _supplyControl;
    }

    /**
        @notice set new pair address with fee
        @param _addr address
     */
    function setPairFee(address _addr) public onlyOwner {
        _pairWithFee[_addr] = true;
    }

    /**
        @notice set new fee receivers
        @param _addr address
     */
    function toggleWhitelist(address _addr) public onlyOwner {
        _isFeeExempt[_addr] = !_isFeeExempt[_addr];
    }
}