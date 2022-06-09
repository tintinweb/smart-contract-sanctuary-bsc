/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function callOptionalReturn(ERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ICO is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // The  PLXS contract
    ERC20 private _plxs;

    // The BUSD contract
    ERC20 private _busd;


    // Address where funds are collected
    address payable private _wallet;

    // How many PLXS units a buyer gets per BUSD.
    // The rate is the conversion between BUSD and PLXS unit.
    uint256 private _busdRate;

    // How many PLXS units a buyer gets per BNB.
    // The rate is the conversion between BNB and PLXS unit.
    uint256 private _bnbRate;

    // Amount of PLXS Delivered
    uint256 private _plxsDelivered;

    event PlxsPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor (uint256 busdRate, uint256 bnbRate, address payable wallet, ERC20 busd, ERC20 plxs) public {
        require(busdRate > 0, "ICO: busdRate shouldn't be Zero");
        require(bnbRate > 0, "ICO: ethRate shouldn't be Zero");
        require(wallet != address(0), "ICO: wallet is the Zero address");
        require(address(plxs) != address(0), "ICO: token is the Zero address");

        _busdRate = busdRate;
        _bnbRate = bnbRate;
        _wallet = wallet;
        _busd = busd;
        _plxs = plxs;
    }

    function plxsAddress() public view returns (ERC20) {
        return _plxs;
    }

    function busdAddress() public view returns (ERC20) {
        return _busd;
    }


    function teamWallet() public view returns (address payable) {
        return _wallet;
    }

    function busdRate() public view returns (uint256) {
        return _busdRate;
    }

    function bnbRate() public view returns (uint256) {
        return _bnbRate;
    }

    function plxsDelivered() public view returns (uint256) {
        return _plxsDelivered;
    }

    function buyPlxsWithBusd(uint256 busdAmount) public nonReentrant {
        address beneficiary = _msgSender();
        uint256 ContractBalance = _plxs.balanceOf(address(this));
        uint256 allowance = _busd.allowance(beneficiary, address(this));

        require(busdAmount > 0, "You need to send at least one BUSD");
        require(allowance >= busdAmount, "Check the BUSD allowance");

        // calculate PLXS amount
        uint256 _plxsAmount = _getBusdRate(busdAmount);

        _preValidatePurchase(beneficiary, _plxsAmount);

        require(_plxsAmount <= ContractBalance, "Not enough PLXS in the reserve");

        // update state
        _plxsDelivered = _plxsDelivered.add(_plxsAmount);

        _busd.safeTransferFrom(beneficiary, address(this), busdAmount);

        _processPurchase(beneficiary, _plxsAmount);

        emit PlxsPurchased(_msgSender(), beneficiary, busdAmount, _plxsAmount);

        _updatePurchasingState(beneficiary, _plxsAmount);

        _forwardBusdFunds(busdAmount);
        _postValidatePurchase(beneficiary, _plxsAmount);
    }

    function () external payable {
        buyPlxsWithBnb();
    }

    function buyPlxsWithBnb() public nonReentrant payable {
        address beneficiary = _msgSender();
        uint256 bnbAmount = msg.value;
        uint256 ContractBalance = _plxs.balanceOf(address(this));

        require(bnbAmount > 0, "You need to send at least some BNB");

        // calculate PLXS amount
        uint256 _plxsAmount = _getBnbRate(bnbAmount);

        _preValidatePurchase(beneficiary, _plxsAmount);

        require(_plxsAmount <= ContractBalance, "Not enough PLXS in the reserve");

        // update state
        _plxsDelivered = _plxsDelivered.add(_plxsAmount);

        _processPurchase(beneficiary, _plxsAmount);

        emit PlxsPurchased(_msgSender(), beneficiary, bnbAmount, _plxsAmount);

        _updatePurchasingState(beneficiary, _plxsAmount);

        _forwardBnbFunds();

        _postValidatePurchase(beneficiary, _plxsAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 Amount) internal view {
        require(beneficiary != address(0), "ICO: beneficiary is the zero address");
        require(Amount != 0, "ICO: Amount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    function _postValidatePurchase(address beneficiary, uint256 Amount) internal view {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _deliverPlxs(address beneficiary, uint256 plxsAmount) internal {
        _plxs.safeTransfer(beneficiary, plxsAmount);
    }

    function _processPurchase(address beneficiary, uint256 plxsAmount) internal {
        _deliverPlxs(beneficiary, plxsAmount);
    }

    function _updatePurchasingState(address beneficiary, uint256 Amount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _getBusdRate(uint256 busdAmount) internal view returns (uint256) {
        return busdAmount.mul(_busdRate);
    }

    function _getBnbRate(uint256 bnbAmount) internal view returns (uint256) {
        return bnbAmount.mul(_bnbRate);
    }

    function _forwardBusdFunds(uint256 busdAmount) internal {
        _busd.safeTransfer(_wallet, busdAmount);
    }

    function _forwardBnbFunds() internal {
        _wallet.transfer(msg.value);
    }
}

contract LimitedUnitsIco is ICO {
    using SafeMath for uint256;

    uint256 private _maxPlxsUnits;

    constructor (uint256 maxPlxsUnits) public {
        require(maxPlxsUnits > 0, "Max Capitalization shouldn't be Zero");
        _maxPlxsUnits = maxPlxsUnits;
    }

    function maxPlxsUnits() public view returns (uint256) {
        return _maxPlxsUnits;
    }

    function icoReached() public view returns (bool) {
        return plxsDelivered() >= _maxPlxsUnits;
    }

    function _preValidatePurchase(address beneficiary, uint256 Amount) internal view {
        super._preValidatePurchase(beneficiary, Amount);
        require(plxsDelivered().add(Amount) <= _maxPlxsUnits, "Max PLXS Units exceeded");
    }
}

contract PlxsIco is LimitedUnitsIco {

    uint256 internal constant _hundredMillion = 10 ** 8;
    uint256 internal constant _onePlxs = 10**18;
    uint256 internal constant _maxPlxsUnits = _hundredMillion * _onePlxs;
    uint256 internal constant _oneBusdToPlxs = 100;
    uint256 internal constant _oneBnbToPlxs = 43500;

    address payable _wallet = 0x44fe0A5a23c271BE8eb911F53444b41364FdB52A;
    ERC20 internal _busd = ERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    ERC20 internal _plxs = ERC20(0xf3235759Ed00D5477E1fce64F581EBc8b9E79f4C);

    constructor () public
    ICO(_oneBusdToPlxs, _oneBnbToPlxs, _wallet, _busd, _plxs)
    LimitedUnitsIco(_maxPlxsUnits)
    {

    }
}