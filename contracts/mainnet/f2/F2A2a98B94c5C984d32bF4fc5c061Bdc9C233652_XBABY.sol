/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakePair {
    function PERMIT_TYPEHASH() external pure returns (bytes32);
}

interface AutoLP {
   function execute(
        uint256 fromtype, //1buy 2sell
        uint256 amount,
        uint256 feeAddbabyLp,
        uint256 feeAddnvwaLp
    ) external returns (uint256);

    function setBabyStatus(bool _status) external;
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
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

   
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
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

contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

contract CalledLPContract {   
    bytes32 public constant PANCAKE_PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9; 
    function getPERMITTYPEHASH(address lp) external pure returns(bool){
        return IPancakePair(lp).PERMIT_TYPEHASH() == PANCAKE_PERMIT_TYPEHASH;
    }
}

contract XBABY is Context, IERC20, Ownable{
    using SafeMath for uint256;
    using Address for address;
    uint8 private _decimals = 18;    
    uint256 private _total = 9000000 * 10**18; 
    string private _name = "XBABY";  
    string private _symbol = "XBABY";

    address public buyPoolReward;
    address public buyFund;
    address public buyNodeReward;
    

    address public sellToAddlp;
    address public sellFund;

    CalledLPContract public externalContract;

    AutoLP public lpBot;


    mapping (address => uint256) private _balance;
    mapping (address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public openLP; 

    constructor()public{
        _owner = msg.sender;
        _isExcludedFromFee[msg.sender]=true;
        _balance[msg.sender] = _total;
        emit Transfer(address(0), msg.sender, _total);
        
        externalContract = new CalledLPContract();

        buyPoolReward = 0xb1757888b3d28e0F464AAd1DdbFc39213c34751D;
        buyFund = 0x545BC4b0D6329F7b98dE9207FcFE9D66c3268E9e;
        buyNodeReward = 0x722AB4AFF5eC2cb531eD4900Ec2C1D823b0ac47b;
        sellFund = 0xCeec63D05469E20a5Bba5Ac11A1553096d848cFf;
    }

    function excludeFromFees(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }

    function includeInFees(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            _isExcludedFromFee[accounts[i]] = false;
        }
    }

    function setBuyPoolRewardAddr(address _buyPoolReward) public onlyOwner {
        buyPoolReward=_buyPoolReward;
    }

    function setBuyNodeRewardAddr(address _buyNodeReward) public onlyOwner {
        buyNodeReward=_buyNodeReward;
    }
    function setbuyFundAddr(address _buyFund) public onlyOwner {
        buyFund=_buyFund;
    }
    function setSellADDBABYLP(address _sellToAddlp) public onlyOwner {
        sellToAddlp=_sellToAddlp;
    }
    function setSellFundAddr(address _sellFund) public onlyOwner {
        sellFund=_sellFund;
    }
    function setLpBot(AutoLP _lpBot) public onlyOwner {
        lpBot=_lpBot;
    }
    function setOpenLP(address lp, bool state) public onlyOwner {
        openLP[lp]=state;
    }
   
    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance.sub(subtractedValue));
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
            _approve(owner, spender, currentAllowance.sub(amount));
        }
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
        return _total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balance[from]>=amount,"Balance Error!");

        bool buyFee = false;
        bool sellFee = false;
        uint256 fromtype =0;

        if (isPairs(to)){ 
            require(openLP[to],"LP Not Open");
            buyFee =false;
            sellFee =true;
            fromtype =2;
        }
        if(isPairs(from)){ 
            require(openLP[from],"LP Not Open");
            buyFee =true;
            sellFee =false;
            fromtype =1;
        }
        if( _isExcludedFromFee[from] || _isExcludedFromFee[to]){ 
            buyFee =false;
            sellFee =false;
            fromtype =0;
        }
        if(to == address(lpBot)){
            buyFee =false;
            sellFee =false;
            fromtype =6;

        }

        (, ,,uint256 d)=calcBuyFee(buyFee, amount);
        (uint256 feeAddbabyLp,uint256 feeAddnvwaLp,,uint256 h)=calcSellFee(sellFee, amount);
        uint256 allfee = d.add(h);
        uint256 sendAmount = amount.sub(allfee);

        _balance[from] = _balance[from].sub(amount);
        _balance[to] = _balance[to].add(sendAmount);
        emit Transfer(from, to, sendAmount);

        _tokenTransfer(buyFee,sellFee,from,amount);

        if(address(lpBot) != address(0)){
            lpBot.execute(fromtype, amount, feeAddbabyLp, feeAddnvwaLp);
        }
    }


    function _tokenTransfer(bool _buyFee, bool _sellFee,address _from, uint256 _amount) private returns(uint256) {
        (uint256 a,uint256 b,uint256 c,)=calcBuyFee(_buyFee, _amount);
        (uint256 e,uint256 f,uint256 g,)=calcSellFee(_sellFee, _amount); 

        if(a>0){
            _take(_from,buyPoolReward,a);
        }
        if(b>0){
            _take(_from,buyFund,b);
        }
        if(c>0){
            _take(_from,buyNodeReward,c);
        }
        if(e>0){ 
            uint256 addlpAmount=e.add(f);
            _take(_from,sellToAddlp,addlpAmount);
        }
        if(g>0){
            _take(_from,sellFund,g);
        }
    }


    function calcBuyFee(bool _buyFee ,uint256 _amount)private pure returns(uint256,uint256,uint256,uint256){
        uint256 buyPoolRewardAmount =0;
        uint256 buyNodeRewardAmount =0;
        uint256 buyFundAmount =0;
        
        if(_buyFee){
            buyPoolRewardAmount = _amount.mul(3).div(100);
            buyFundAmount = _amount.mul(3).div(100);
            buyNodeRewardAmount = _amount.mul(2).div(100);
        }
        uint256 fall=buyPoolRewardAmount.add(buyFundAmount).add(buyNodeRewardAmount);
        return (buyPoolRewardAmount,buyFundAmount,buyNodeRewardAmount,fall);

    }
    function calcSellFee(bool _sellFee ,uint256 _amount)private pure returns(uint256,uint256,uint256,uint256){
        uint256 sellADDNVWALPAmount =0;
        uint256 sellADDBABYLPAmount =0;
        uint256 sellFundAmount =0;
        
        if(_sellFee){
            sellADDNVWALPAmount = _amount.mul(5).div(100);
            sellADDBABYLPAmount = _amount.mul(5).div(100);
            sellFundAmount = _amount.mul(5).div(100);
        }
        uint256 fall=sellADDNVWALPAmount.add(sellADDBABYLPAmount).add(sellFundAmount);
        return (sellADDNVWALPAmount,sellADDBABYLPAmount,sellFundAmount,fall);
    }

    function _take(address from,address to,uint256 amount) private {
        _balance[to] = _balance[to] + amount;
        emit Transfer(from, to, amount);
    }

    function isPairs(address addr) private view returns(bool){
        bool isContract = addr.isContract(); 
        if(isContract){ 
            bool isLP;
            try externalContract.getPERMITTYPEHASH(addr) {
                isLP =  true;
            }catch{
                isLP =false;
            }
            return isLP;

        }else{
            return false;
        }
    }
    function manageToken(address _token,uint256 _amount) external onlyOwner {
        uint256 amount = _amount;
        if(_amount == 0){
            amount = IERC20(_token).balanceOf(address(this));
        }
        IERC20(_token).transfer(msg.sender, amount);
    }
    function manageValue() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

}