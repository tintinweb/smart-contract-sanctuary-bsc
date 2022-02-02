/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// Token 005

// testnet
// 

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;





contract Token005 {

    uint public constant MAX = type(uint256).max;

    string public name = "Token 005";
    string public symbol = "T005";
    uint public decimals = 18;
    uint public totalSupplyAtLaunch = 100_000_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;
    uint public inCirculation;
   
    // MAINNET
    //address public addressRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


    // TESTNET addresses
    address public addressBurn = payable(0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D); // TESTNET burn   
    address public addressDev = payable(0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca); // TESTNET dev 
    address public addressMarketing = payable(0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a); // TESTNET marketing
    address public addressReward = payable(0xd360A90144a3ea66C35D01E4Ad969Df41f607479); // TESTNET reward
    
    //address public addressRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // TESTNET pancakeRouter code OFFICIAL PCS address

    address public addressRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // TESTNET pancakeRouter code on https://pancake.kiemtienonline360.com/#/swap
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // TESTNET WBNB on https://pancake.kiemtienonline360.com/#/swap


    //IDEXRouter public router;
    //address public pair;

    uint8 public taxDev;
    uint8 public taxMarketing;
    uint8 public taxReward;
    uint8 public taxTransfer;
    
    bool public isTradingEnabled;
    uint public tradingEnabledTime; 

    address payable public token;
    address payable public deployer;      
    address payable public owner;



    mapping(address => uint) private balance;
    mapping(address => mapping(address => uint)) private budget;

    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt; // not taxed and not receiving reward
    /*
    mapping(address => bool) private exemptTax; // not taxed
    mapping(address => bool) private exemptReward; // not receive reward
    */
    
    modifier isAuthorised() { require(msg.sender == owner, "Not authorised"); _; }
    //modifier notBlacklisted() { require(!blacklist[msg.sender], "Is blacklisted"); _; }

    event Approval(address indexed holder, address indexed spender, uint amount);
    event Burn(address indexed from, address indexed to, uint amount); 
    event Transfer(address indexed from, address indexed to, uint amount);
    event TransferFrom(address indexed from, address indexed to, uint amount, address indexed spender);

    receive() external payable {}

    constructor() {

        token = payable(address(this));
        //budget[token][addressRouter] = MAX;
        //emit Approval(token, addressRouter, MAX); 

        owner = payable(msg.sender);
        balance[owner] = totalSupplyAtLaunch;
        emit Transfer(address(0), owner, totalSupplyAtLaunch);
        //budget[owner][addressRouter] = MAX;
        //emit Approval(owner, addressRouter, MAX);

        //router = IDEXRouter(addressRouter);
        //pair = IDEXFactory(router.factory()).createPair(router.WETH(), token);

        exempt[token] = true;        
        exempt[owner] = true;
        exempt[addressBurn] = true;
        exempt[addressDev] = true;
        exempt[addressMarketing] = true;
        exempt[addressReward] = true;
        exempt[addressRouter] = true;


        /*
        exemptTax[address(this)] = true;
        exemptTax[owner] = true;
        exemptTax[addressBurn] = true;
        exemptTax[addressDev] = true;
        exemptTax[addressMarketing] = true;
        exemptTax[addressReward] = true;
     
        exemptReward[address(this)] = true;
        exemptReward[owner] = true;
        exemptReward[addressBurn] = true;
        exemptReward[addressDev] = true;
        exemptReward[addressMarketing] = true;
        exemptReward[addressReward] = true;
        */
   
    }
  

    function approve(address spender, uint amount) public returns(bool) {
        require(msg.sender != address(0) && spender != address(0), "Null address");
        require(amount != 0, "Zero amount");
        budget[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;   
    }

    function balanceOf(address holder) public view returns(uint){
        return balance[holder];
    }

    function blacklistAdd(address holder) public isAuthorised {
        blacklist[holder] = true;
    }
    function blacklistRemove(address holder) public isAuthorised {
        require(blacklist[holder] == true, "Address not in blacklist");
        blacklist[holder] = false;
    } 
    function isBlacklisted(address holder) public view isAuthorised returns(bool){
        return blacklist[holder];
    }

    /*
    // NOTE - who holds total supply... owner or token ???
    function burn(uint amount) public isAuthorised returns(bool) {
        //require(totalSupply - inCirculation >= amount, "Amount too big: burn()");
        balance[token] -= amount;
        balance[addressBurn] += amount;
        totalSupply -= amount;         
        emit Burn(token, addressBurn, amount);
        return true;
    }
    */

    function enableTrading() public isAuthorised {
        require(isTradingEnabled == false, "Trading already enabled");
        taxDev = 10;
        taxMarketing = 5;
        taxReward = 0;
        taxTransfer = 1;
        tradingEnabledTime = block.timestamp;
        isTradingEnabled = true;
    }


    // rescue BNB / tokens



    function setName(string memory textN, string memory textS ) public isAuthorised {
        name = textN;
        symbol = textS;
    }

    /*
    function swapTokensForBNB(uint amount) public isAuthorised {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            addressDev,
            block.timestamp + 30
        );
     }
     */


    function transfer(address to, uint amount) public returns(bool) {
        require(isTradingEnabled == true, "Trading not enabled: transfer()");
        address from = msg.sender;
        require(!blacklist[from], "From address blacklisted: transfer()");
        require(amount <= balance[from], "From balance too small: transfer()");
        
        balance[from] -= amount;

        uint _taxT;
        if (!exempt[to]){
            _taxT = ( amount * taxTransfer ) / 100;
            balance[addressReward] += _taxT; 
        }

        balance[to] += amount - _taxT;

        emit Transfer(from, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint amount) public returns(bool) {
        require(isTradingEnabled == true, "Trading not enabled: transferFrom()");
        require(!blacklist[from], "From address blacklisted: transferFrom()");
        require(balance[from] >= amount, "From balance too small: transferFrom()");
        address spender = msg.sender;
        require(budget[from][spender] >= amount, "Spender budget too small: transferFrom()");
        
        balance[from] -= amount;
        budget[from][spender] -= amount;
  
        uint _taxD;
        uint _taxM;
        uint _taxR;
        if (!exempt[to]){
            _taxD = ( amount * taxDev ) / 100;
            _taxM = ( amount * taxMarketing ) / 100;
            _taxR = ( amount * taxReward ) / 100;
            balance[addressDev] += _taxD;
            balance[addressMarketing] += _taxM;
            balance[addressReward] += _taxR; 
        }

        balance[to] += amount - ( _taxD + _taxM + _taxR );
        
        emit TransferFrom(from, to, amount, spender);
        return true;   
    }

}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}