// SPDX-License-Identifier: MIT


pragma solidity ^0.6.2;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

interface IECBNFT {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function dispatchHandle() external view returns (address);
    function claim(address token, address account) external;
}

contract ECB is ERC20, Ownable {
    using SafeMath for uint256;

    address public uniswapV2Pair;
    IUniswapV2Router02 router;
    IECBNFT nft;

    mapping(address => bool) public ammPairs;

    uint256 public currentIndex;
    uint256 public distributorGas = 500000;
    address[] public shareholders;
    mapping(address => bool) private _updated;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public lastLPDividends;
    uint256 public minPeriod = 1 hours;

    uint256 toLP = 100;
    uint256 toNFT = 100;
    uint256 toBurn = 50;
    uint256 toOpt = 50;
    uint256 totalFees = 300;

    uint256 public constant base = 10000;
    uint256 private constant _totalBurn = 9900000 * 10**18;

    uint256 public totalDividendsDistributed;

    address public USDT = address(0x55d398326f99059fF775485246999027B3197955); //USDT
    address public mainAddress = 0x0c483A3Df82d505C5E850E10024B3fa47AAe7a62;
    address public operationAddress = 0x1ceDC53F3f6FaEB14b68B20b810dcbEd86029dB1;
    address public lpAddress = 0xe2c8E2CC7655c17e710238EC1F82e84705501c8b;


    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public isDividendExempt;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BindReferrer(address indexed account,address indexed referrer);
    event BindReferrerError(address indexed account,address indexed referrer);


    constructor() public ERC20("ECB", "ECB") {

         require(USDT < address(this), "contract address must be token1");

        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        nft = IECBNFT(0x8C83bd02a9096Bb25CA3560aa19B9D3b73849A4e);
        // Create a uniswap pair for this new token
        address _pancakeV2Pair = IUniswapV2Factory(router.factory())
        .createPair(address(this), USDT);

        uniswapV2Pair = _pancakeV2Pair;
        ammPairs[_pancakeV2Pair] = true;



        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(mainAddress, true);
        excludeFromFees(operationAddress, true);
        excludeFromFees(lpAddress, true);
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[lpAddress] = true;

        uint256 _total = 10000000 * (10 ** 18);
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(mainAddress, _total);
        lastLPDividends = block.timestamp;
    }

    receive() external payable {

    }

    function setVariable(uint256 variate, address newAddress) external onlyOwner {
        if (variate == 1) operationAddress = newAddress;
        if (variate == 2) lpAddress = newAddress;
    }

    function setAmmPair(address pair, bool hasPair) external onlyOwner {
        ammPairs[pair] = hasPair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "ECB: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel){
        if (ammPairs[to]) {
            address token0 = IUniswapV2Pair(to).token0();
            (uint r0,,) = IUniswapV2Pair(to).getReserves();
            uint bal0 = IERC20(token0).balanceOf(to);
            if (token0 != address(this) && bal0 > r0) {
                isAdd = bal0 - r0 > 1e6;
            }
        }
        if (ammPairs[from]) {
            address token0 = IUniswapV2Pair(from).token0();
            (uint r0,,) = IUniswapV2Pair(from).getReserves();
            uint bal0 = IERC20(token0).balanceOf(from);
            if (token0 != address(this) && bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
        }
    }

    function burn(uint256 amount) public {
        if (balanceOf(address(0)) >= _totalBurn) {
            return;
        }
        super._burn(msg.sender,amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ECB: transfer from the zero address");
        require(to != address(0), "ECB: transfer to the zero address");
        require(amount > 0, "ECB: Transfer amount must be greater than zero");

        if (from == nft.dispatchHandle()) {
            super._transfer(from, to, amount);
            return;
        }

        if (!isDividendExempt[from] && from != uniswapV2Pair) setShare(from);
        if (!isDividendExempt[to] && to != uniswapV2Pair) setShare(to);

        bool swap = false;
        if ((ammPairs[to] && !_isExcludedFromFees[from]) || (ammPairs[from] && !_isExcludedFromFees[to])) {
            (bool isAddLiquidity,bool isDelLiquidity) = _isLiquidity(from, to);
            if (!isAddLiquidity && !isDelLiquidity) {
                swap = true;
            }
            if (isAddLiquidity && !isDividendExempt[from] && !_updated[from]) {
                addShareholder(from);
            }
        }

        uint256 toTransferAmount = amount;
        uint256 fees = 0;
        if (swap) {
            fees = amount.mul(totalFees).div(base);
            toTransferAmount = amount.sub(fees);
        }
        if (fees > 0) {
            super._transfer(from, address(this), fees);
            uint256 _toNFT = fees.mul(toNFT).div(totalFees);
            uint256 _toBurn = fees.mul(toBurn).div(totalFees);
            uint256 _toOpt = fees.mul(toOpt).div(totalFees);
            if (_toNFT > 0) {
                super._transfer(address(this), nft.dispatchHandle(), _toNFT);
            }
            if (_toBurn > 0 && balanceOf(address(0)).add(_toBurn) <= _totalBurn) {
                super._burn(address(this), _toBurn);
            }
            if (_toOpt > 0) {
                super._transfer(address(this), operationAddress, _toOpt);
            }
            totalDividendsDistributed = totalDividendsDistributed.add(fees);
        }
        if (
            balanceOf(address(this)) >= 100 * 10**18 &&
            from != address(this) &&
            lastLPDividends.add(minPeriod) <= block.timestamp
        ) {
            process(distributorGas);
            lastLPDividends = block.timestamp;
        }
        if (!isContract(from)) nft.claim(address(this), from);
        if (!isContract(to)) nft.claim(address(this), to);
        super._transfer(from, to, toTransferAmount);
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function withdraw(address asses, uint256 amount, address ust) public onlyOwner {
        IERC20(asses).transfer(ust, amount);
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) {
                removeShareholder(shareholder);
            }
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
        _updated[shareholder] = true;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
        _updated[shareholder] = false;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;
        uint256 nowBalance = balanceOf(address(this));
        uint256 exempt = IERC20(uniswapV2Pair).balanceOf(lpAddress);
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            uint256 amount = nowBalance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(
                IERC20(uniswapV2Pair).totalSupply().sub(exempt)
            );
            if (amount < 1 * 10**18) {
                currentIndex++;
                iterations++;
                return;
            }
            if (balanceOf(address(this)) < amount) return;
            super._transfer(address(this), shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
}