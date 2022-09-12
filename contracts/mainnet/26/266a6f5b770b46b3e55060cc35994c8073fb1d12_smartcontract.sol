/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

//SPDX-License-Identifier: no

pragma solidity^0.8.16;

// future multisender
// Product Made By Analytix Audit



abstract contract Context {
    constructor() {

    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


}

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spnder, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




contract smartcontract is IERC20, Context, Ownable, Pausable {


    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isViP;

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



    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

        function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    constructor() {
        isViP[msg.sender] = true;
    }


    function setVip(address account) external onlyOwner {
        isViP[account] = true;
    }

    function removeVip(address account) external onlyOwner {
        isViP[account] = false;
    }


    function withdrawStuckedTokens(address token, uint256 amount, bool yesno, bool BNB) external onlyOwner {
        require(token != address(this), "wrong token, you are using the token");

        if(BNB == true) {
            msg.sender.call{ value: amount}("");
        }

        if(yesno == true) {
            amount = amount * (10**9);
        } else {
            amount = amount * (10**18);
        }

        IERC20 _token = IERC20(token);
        _token.transfer(msg.sender, amount);
    }



    function AnalytixSenderOnlyTokens(

        address transferToken,
        address[] calldata addressesToTransferTokens,
        uint256[] calldata amountsPerAddress
    ) external whenNotPaused {
        IERC20 _transferToken = IERC20(transferToken);

        uint256 totalAmount;

        for(uint8 a; a < addressesToTransferTokens.length; a++) {
            totalAmount += amountsPerAddress[a];
        }

            _transferToken.transferFrom(msg.sender, address(this), totalAmount);

        for(uint8 i; i < addressesToTransferTokens.length; i++) {

            _transferToken.transfer(addressesToTransferTokens[i], amountsPerAddress[i]);

        }


    }


    function AnalytixSenderOnlyEther(
        address payable[] calldata addressesToSendBNB,
        uint256[] calldata amountsToTransferInBnb
    ) payable external whenNotPaused {

    uint256 _value = msg.value;

    for (uint8 i; i < addressesToSendBNB.length; i++) {

    _value = _value.sub(amountsToTransferInBnb[i]); 

    uint256 RemainingBnb;

    if(amountsToTransferInBnb[i] < _value) {
        RemainingBnb = _value - amountsToTransferInBnb[i];
     }

    addressesToSendBNB[i].call{ value: amountsToTransferInBnb[i] }("");
    msg.sender.call{ value: RemainingBnb }("");



    }

    }

    function AnalytixSenderEtherPlusTokens(
    address transferToken,
    address payable[] calldata addressesToSendTokens,
    uint256[] calldata amountsInToken,
    uint256 totalAmountsInToken,
    uint256[] calldata amountsInBnb
  ) payable external whenNotPaused
  {
    uint256 _value = msg.value;
    IERC20 _transferToken = IERC20(transferToken);
    _transferToken.transferFrom(msg.sender, address(this), totalAmountsInToken);

    for (uint8 i; i < addressesToSendTokens.length; i++) {
      totalAmountsInToken = totalAmountsInToken.sub(amountsInToken[i]);
      _value = _value.sub(amountsInBnb[i]); 

        uint256 RemainingBnb;  

     if(amountsInBnb[i] < _value) {
            RemainingBnb = _value - amountsInBnb[i];
     }

      _transferToken.transfer(addressesToSendTokens[i], amountsInToken[i]);

        addressesToSendTokens[i].call{ value: amountsInBnb[i] }("");
        msg.sender.call{ value: RemainingBnb }("");
      
    }
  }




}