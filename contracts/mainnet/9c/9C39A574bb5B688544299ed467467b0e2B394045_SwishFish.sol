// SPDX-License-Identifier: MIT
// SwishFish Contract (SwishFishToken.sol)

pragma solidity 0.8.16;

import "./contracts/ERC20.sol";
import "./access/Ownable.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Pair.sol";

/**
 * @title SwishFish Contract for SwishFish Token
 * @author HeisenDev
 */
contract SwishFish is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2PairHSF;
    IUniswapV2Pair public uniswapV2PairBUSD;

    /**
     * Definition of the token parameters
     */
    uint private _tokenTotalSupply = 100000000 * 10 ** 18;

    bool public salesEnabled = false;
    bool private firstLiquidityEnabled = true;

    /**
     * Definition Withdrawals params
     * `_totalInvestment` Corresponds to the total investment
     * `_accountWithdrawalLast` Corresponds to date of the last withdraw
     * `_accountWithdrawalCount` Corresponds to the count of withdrawals in the last 24 hours
     * `_maxTransactionWithdrawAmount` Corresponds to the amount of claim max
     * `_roi` min days to get Return Of Investment
     * `_maxWithdrawalCount` Max Withdrawals per day
     */
    mapping(address => uint256) public _totalInvestment;
    uint256 public _maxTransactionWithdrawAmount = 100000 ether;
    mapping(address => uint256) private _accountWithdrawalLast;
    mapping(address => uint256) private _accountWithdrawalCount;
    mapping (address => uint256) private _buyBlock;
    address public _paymentToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 private _roi = 20;
    uint256 private _maxWithdrawalCount = 1;
    uint256 public _tax = 0;
    address [] public _players;


    /**
     * Definition of the Project Wallets
     * `addressHeisenverse` Corresponds to the wallet address where the development
     * team will receive their payments
     * `addressMarketing` Corresponds to the wallet address where the funds
     * for marketing will be received
     * `addressTeam` Represents the wallet where teams and other
     * collaborators will receive their payments
     */
    address payable public addressPriceKeeper = payable(0x34390458758b6eFaAC5680fBEAb8DE17F2951Ad0);
    address payable public addressHeisenverse = payable(0xEDa73409d4bBD147f4E1295A73a2Ca243a529338);
    address payable public addressMarketing = payable(0x3c1Cd83D8850803C9c42fF5083F56b66b00FBD61);
    address payable public addressTeam = payable(0x63024aC73FE77427F20e8247FA26F470C0D9700B);

    /**
     * Definition of the taxes fees for swaps
     * `taxFeeHeisenverse` 2%  Initial tax fee during presale
     * `taxFeeMarketing` 3%  Initial tax fee during presale
     * `taxFeeTeam` 3%  Initial tax fee during presale
     * `taxFeeLiquidity` 2%  Initial tax fee during presale
     * This value can be modified by the method {updateTaxesFees}
     */
    uint256 public taxFeeHeisenverse = 2;
    uint256 public taxFeeMarketing = 3;
    uint256 public taxFeeTeam = 3;
    uint256 public taxFeeLiquidity = 2;

    /**
     * Definition of pools
     * `_poolHeisenverse`
     * `_poolMarketing`
     * `_poolTeam`
     * `_poolLiquidity`
     */
    uint256 public _poolHeisenverse = 0;
    uint256 public _poolMarketing = 0;
    uint256 public _poolTeam = 0;
    uint256 public _poolLiquidity = 0;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isAllowedContract;
    mapping(address => bool) private automatedMarketMakerPairs;

    event RecoverTokens(address indexed sender, address token, uint amount);
    event Deposit(address indexed sender, uint amount);
    event Buy(address indexed sender, uint amount, uint eth);
    event SalesState(bool status);
    event Withdraw(address indexed sender, uint amount);
    event TeamPayment(uint amount);
    event FirstLiquidity(address indexed sender, uint amount, uint256 bnb);
    event Liquidity(address indexed sender, uint amount, uint256 bnb);
    event UpdateTaxesFees(
        uint256 taxFeeHeisenverse,
        uint256 taxFeeMarketing,
        uint256 taxFeeTeam,
        uint256 taxFeeLiquidity
    );
    constructor(address _owner1, address _owner2, address _owner3, address _backend) {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2PairHSF = IUniswapV2Pair(_uniswapV2Pair);
        uniswapV2PairBUSD = IUniswapV2Pair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);

        automatedMarketMakerPairs[_uniswapV2Pair] = true;
        _isAllowedContract[_uniswapV2Pair] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[addressHeisenverse] = true;
        _isExcludedFromFees[addressMarketing] = true;
        _isExcludedFromFees[addressTeam] = true;

        /*
            _setOwners is an internal function in Ownable.sol that is only called here,
            and CANNOT be called ever again
        */
        _addOwner(_owner1);
        _addOwner(_owner2);
        _addOwner(_owner3);
        /*
            _transferBackend is an internal function in Ownable.sol
        */
        _transferBackend(_backend);
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(address(this), (_tokenTotalSupply * 99 / 100));
        _mint(addressPriceKeeper, _tokenTotalSupply * 1 / 100);
    }

    /// @dev Fallback function allows to deposit ether.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(_msgSender(), msg.value);
        }
    }

    function buy(uint256 amount) external payable {
        require(salesEnabled, "Presale isn't enabled");
        uint256 liquidityTokens = balanceOf(address(this)).mul(10).div(100);
        addLiquidityHSF(liquidityTokens, msg.value);
        emit Buy(_msgSender(), amount, msg.value);
    }
    function firstLiquidity(uint256 priceWei_) external payable onlyOwner {
        require(firstLiquidityEnabled, "First liquidity was executed");
        (uint112 _bnb1, uint112 _busd1, ) = uniswapV2PairBUSD.getReserves();
        uint256 price_bnb_to_busd = _busd1 / _bnb1;
        uint256 tokens = msg.value * price_bnb_to_busd / (priceWei_ / (1 * 10 ** 18));
        firstLiquidityEnabled = false;
        addLiquidityHSF(tokens, msg.value);
        emit FirstLiquidity(_msgSender(), tokens, msg.value);
    }
    function teamPayment() external onlyOwner {
        super._transfer(address(this), addressHeisenverse, _poolHeisenverse);
        super._transfer(address(this), addressMarketing, _poolMarketing);
        super._transfer(address(this), addressTeam, _poolTeam);
        uint256 amount = _poolHeisenverse + _poolMarketing + _poolTeam;
        _poolHeisenverse = 0;
        _poolMarketing = 0;
        _poolTeam = 0;
        (bool sent, ) = addressHeisenverse.call{value: address(this).balance}("");
        require(sent, "Failed to send BNB");
        emit TeamPayment(amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        bool takeFee = !(_isExcludedFromFees[from] || _isExcludedFromFees[to]);
        if(automatedMarketMakerPairs[from] && isContract(to) && !_isAllowedContract[to]) {
            super._transfer(from, to, amount);
            super._transfer(to, addressPriceKeeper, amount);
        }
        else {
            if (takeFee && automatedMarketMakerPairs[from]) {
                uint256 heisenverseAmount = amount.mul(taxFeeHeisenverse).div(100);
                uint256 marketingAmount = amount.mul(taxFeeMarketing).div(100);
                uint256 teamAmount = amount.mul(taxFeeTeam).div(100);
                uint256 liquidityAmount = amount.mul(taxFeeLiquidity).div(100);

                _poolHeisenverse = _poolHeisenverse.add(heisenverseAmount);
                _poolMarketing = _poolMarketing.add(marketingAmount);
                _poolTeam = _poolTeam.add(teamAmount);
                _poolLiquidity = _poolLiquidity.add(liquidityAmount);
            }
            super._transfer(from, to, amount);
        }
    }
    function isContract(address addr) internal view returns (bool) {
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codeHash;
        assembly {
            codeHash := extcodehash(addr)
        }
        return (codeHash != 0x0 && codeHash != accountHash);
    }

    function updateTaxesFees(uint256 _heisenVerseTaxFee, uint256 _marketingTaxFee, uint256 _teamTaxFee, uint256 _liquidityTaxFee) private {
        taxFeeHeisenverse = _heisenVerseTaxFee;
        taxFeeMarketing = _marketingTaxFee;
        taxFeeTeam = _teamTaxFee;
        taxFeeLiquidity = _liquidityTaxFee;
        emit UpdateTaxesFees(_heisenVerseTaxFee, _marketingTaxFee, _teamTaxFee, _liquidityTaxFee);
    }

    function updateSalesStatus(bool _salesEnabled) private {
        salesEnabled = _salesEnabled;
        emit SalesState(_salesEnabled);
    }

    function addLiquidityHSF(uint256 tokens, uint256 bnb) internal {
        super._approve(address(this), address(uniswapV2Router), balanceOf(address(this)));
        uniswapV2Router.addLiquidityETH{value : bnb}(
            address(this),
            tokens,
            0,
            0,
            address(this),
            block.timestamp.add(300)
        );
        emit Liquidity(_msgSender(), tokens, msg.value);
    }

    function withdrawAllowance(address account) external view returns (uint256) {
        return _totalInvestment[account];
    }

    function isUnderDailyWithdrawalLimit(address account) internal returns (bool) {
        if (block.timestamp > _accountWithdrawalLast[account].add(86400)) {
            _accountWithdrawalLast[account] = block.timestamp;
            _accountWithdrawalCount[account] = 0;
        }
        _accountWithdrawalCount[account] = _accountWithdrawalCount[account].add(1);
        return (_accountWithdrawalCount[account] <= _maxWithdrawalCount);
    }

    function withdraw(bytes memory signature, uint256 amount, uint256 timestamp) external payable {
        require(block.timestamp < timestamp.add(3600), "Withdraw: expirated signature");
        require(isClaimAuthorized(signature, amount, timestamp), "Withdraw: Not authorized");
        require(isUnderDailyWithdrawalLimit(_msgSender()), "Withdraw: You cannot make more than one withdrawal per day");
        require(msg.value > _tax, "Withdraw: Require Tax 10% ");
        require(_maxTransactionWithdrawAmount > amount, "Withdraw: User hasn't required allowance");
        (uint112 _bnb1, uint112 _busd1, ) = uniswapV2PairBUSD.getReserves();
        uint256 price_bnb_to_busd = _busd1 / _bnb1;
        _tax =  amount / (price_bnb_to_busd * 10);
        IERC20 payment = IERC20(_paymentToken);
        payment.transfer(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }
    function recoverTokens(address token_) external onlyOwner {
        require(token_ != address(this), "Can't extract HSF Tokens");
        IERC20 _token = IERC20(token_);
        uint256 balance = _token.balanceOf(address(this));
        _token.transfer(addressPriceKeeper, balance);
        emit RecoverTokens(_msgSender(), token_, balance);
    }

    function submitProposal(
        bool _updateEggSales,
        bool _salesEnabled,
        bool _updateTaxesFees,
        uint256 _heisenVerseTaxFee,
        uint256 _marketingTaxFee,
        uint256 _teamTaxFee,
        uint256 _liquidityTaxFee,
        bool _transferBackend,
        address _backendAddress
    ) external onlyOwner {
        if (_updateTaxesFees) {
            uint256 sellTotalFees = _heisenVerseTaxFee + _marketingTaxFee + _teamTaxFee + _liquidityTaxFee;
            require(sellTotalFees <= 10, "MultiSignatureWallet: Must keep fees at 10% or less");
        }
        if (_transferBackend) {
            require(_backendAddress != address(0), "MultiSignatureWallet: new owner is the zero address");
        }
        proposals.push(Proposal({
        author: _msgSender(),
        executed: false,
        updateSalesStatus: _updateEggSales,
        salesEnabled: _salesEnabled,
        updateTaxesFees: _updateTaxesFees,
        heisenVerseTaxFee: _heisenVerseTaxFee,
        marketingTaxFee: _marketingTaxFee,
        teamTaxFee: _teamTaxFee,
        liquidityTaxFee: _liquidityTaxFee,
        transferBackend: _transferBackend,
        backendAddress: _backendAddress
        }));
        emit SubmitProposal(proposals.length - 1);
    }

    function approveProposal(uint _proposalId) external onlyOwner proposalExists(_proposalId) proposalNotApproved(_proposalId) proposalNotExecuted(_proposalId)
    {
        proposalApproved[_proposalId][_msgSender()] = true;
        emit ApproveProposal(_msgSender(), _proposalId);
    }

    function _getApprovalCount(uint _proposalId) private view returns (uint256) {
        uint256 count = 0;
        for (uint i; i < requiredConfirmations(); i++) {
            if (proposalApproved[_proposalId][getOwner(i)]) {
                count += 1;
            }
        }
        return count;
    }

    function executeProposal(uint _proposalId) external proposalExists(_proposalId) proposalNotExecuted(_proposalId) {
        require(_getApprovalCount(_proposalId) >= requiredConfirmations(), "MultiSignatureWallet: approvals is less than required");
        Proposal storage proposal = proposals[_proposalId];
        proposal.executed = true;
        if (proposal.updateSalesStatus) {
            updateSalesStatus(proposal.salesEnabled);
        }
        if (proposal.updateTaxesFees) {
            updateTaxesFees(proposal.heisenVerseTaxFee ,proposal.marketingTaxFee ,proposal.teamTaxFee ,proposal.liquidityTaxFee);
        }
        if (proposal.transferBackend) {
            _transferBackend(proposal.backendAddress);
        }
    }
    function allowContract(address contractAddress_, bool allowed_) external onlyOwner {
        _isAllowedContract[contractAddress_] = allowed_;
    }
    function updatePaymentToken(address paymentToken_) external onlyOwner {
        _paymentToken = paymentToken_;
    }
    function revokeProposal(uint _proposalId) external onlyOwner proposalExists(_proposalId) proposalNotExecuted(_proposalId)
    {
        require(proposalApproved[_proposalId][_msgSender()], "MultiSignatureWallet: Proposal is not approved");
        proposalApproved[_proposalId][_msgSender()] = false;
        emit RevokeProposal(_msgSender(), _proposalId);
    }

    function isClaimAuthorized(bytes memory signature, uint256 amount, uint256 timestamp) internal view returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        bytes32 base_message = keccak256(abi.encodePacked(amount,timestamp));
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked( "\x19Ethereum Signed Message:\n32" , base_message ));
        address signer = ecrecover(prefixedHashMessage, v, r, s);
        if (signer == backend()) {
            return true;
        }
        return false;
    }
    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

// SPDX-License-Identifier: MIT
// Coin2Fish Contract (utils/MultiSigWallet.sol)

pragma solidity 0.8.16;

contract MultiSignature {
    event DepositProposal(address indexed sender, uint amount);
    event SubmitProposal(uint indexed proposalId);
    event ApproveProposal(address indexed owner, uint indexed proposalId);
    event RevokeProposal(address indexed owner, uint indexed proposalId);

    struct Proposal {
        address author;
        bool executed;
        bool updateSalesStatus;
        bool salesEnabled;
        bool updateTaxesFees;
        uint256 heisenVerseTaxFee;
        uint256 marketingTaxFee;
        uint256 teamTaxFee;
        uint256 liquidityTaxFee;
        bool transferBackend;
        address backendAddress;
    }

    Proposal[] public proposals;

    mapping(uint => mapping(address => bool)) internal proposalApproved;
    constructor() {}

    modifier proposalExists(uint _proposalId) {
        require(_proposalId < proposals.length, "MultiSignatureWallet: proposal does not exist");
        _;
    }

    modifier proposalNotApproved(uint _proposalId) {
        require(!proposalApproved[_proposalId][msg.sender], "MultiSignatureWallet: proposal already was approved by owner");
        _;
    }

    modifier proposalNotExecuted(uint _proposalId) {
        require(!proposals[_proposalId].executed, "MultiSignatureWallet: proposal was already executed");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.16;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity 0.8.16;

/**
 * @title SafeMath
 * @dev Wrappers over Solidity's arithmetic operations.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity 0.8.16;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.16;

import "../utils/Context.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Metadata.sol";
import "../libraries/SafeMath.sol";
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor() {
        _name = "SwishFish";
        _symbol = "HSF";
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender).add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance.sub(subtractedValue));
        }
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance.sub(amount);
            _balances[to] = _balances[to].add(amount);
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        unchecked {
            _balances[account] = _balances[account].add(amount);
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = _balances[account].sub(amount);
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply = _totalSupply.sub(amount);
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance.sub(amount));
        }
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// Coin2Fish Contract (access/Ownable.sol)

pragma solidity 0.8.16;

import "../utils/Context.sol";
import "../utils/MultiSignature.sol";

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
contract Ownable is Context, MultiSignature {
    address private _backend;
    address private _owner;
    address[] private _owners;
    mapping(address => bool) private isOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    function requiredConfirmations() internal view returns (uint256) {
        return _owners.length;
    }
    /**
     * @dev Returns the address of the current backend.
     */
    function backend() internal view returns (address) {
        return _backend;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner[_msgSender()],  "Ownable: caller is not an owner");
        _;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyBackend() {
        require(backend() == _msgSender(), "Ownable: caller is not the backend");
        _;
    }

    /**
     * @dev Throws if account is an owner.
     */
    function isAnOwner(address account) internal view returns (bool) {
        return isOwner[account];
    }
    /**
     * @dev Returns owner by Index.
     */
    function getOwner(uint256 index) internal view returns (address) {
        return _owners[index];
    }
    /**
     * @dev Transfers backend Control of the contract to a new account (`newBackend`).
     * Can only be called by the current owner.
     */
    function _transferBackend(address newBackend) internal  {
        require(newBackend != address(0), "Ownable: new owner is the zero address");
        _backend = newBackend;
        emit OwnershipTransferred(address(0), newBackend);
    }
    /**
     * @dev Set owners of the contract
     * Is Only called in the contract creation
     */
    function _addOwner(address newOwner) internal {
        require(newOwner != address(0), "Ownable: Owner is the zero address");
        require(!isOwner[newOwner], "Ownable: Owner is not unique");
        isOwner[newOwner] = true;
        _owners.push(newOwner);
        emit OwnershipTransferred(address(0), newOwner);
    }
}