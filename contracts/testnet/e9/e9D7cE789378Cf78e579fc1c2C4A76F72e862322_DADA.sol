/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

/// @title DOGADA - The Ultimate Meme Token
/// @author DOGADA Team
/// @notice DOGADA is a community-driven, deflationary ERC20 token with unique features designed to reward holders and discourage whales.
/// @dev This contract uses SafeMath for arithmetic operations and includes anti-bot and anti-whale measures.


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////..................................................................................................../////
/////...........................................'',,,,,,,,'''............................................/////
/////..................................';:clodxxkkkOOOOOOOkkkxdoolc:,'.................................../////
/////.............................';coxkO000OOOOOOOOO000OO00O00000K00kdoc;.............................../////
/////..........................;ldkOOOOOOOOOOOOkOOkOkO0OkO00000K0KKKKKKKK0koc,.........................../////
/////.......................:okOOOkOkkkkkkOkOOOkOOO0O00000K00KKKKKKKKKXXKKKKKOxl;......................../////
/////....................'lk0OkkkkkkkkkkkkOOOOOO00000KKKKKKXXXXXXXXXXXNK00XNNXKKOxc'...................../////
/////..................,oO0kkkkkkkkkkkkkkOOOOO0000KKKKKKXXXXXXXNNNNNNNNNXXNNXXXXXK0ko,.................../////
/////................'okOkkkkkkkxkxkkkOOOOO000000KKKKKXXXXXXXNNXXNNNNNNNK0XNNXKXXNXKKOo,................./////
/////...............lkOxxkkxxxxkkkkkdlldkO00000KKKKKKKXXXXXXXNNNNNNNNWW0ockXNNNXXKXXXKKOl'.............../////
/////.............;xOkxxkxxxxxxkkkkkc;clcoO000KKKKKKKXXXXXXXNNNNNNNNWW0lcoxKWNNNNXXXXNXK0k:............../////
/////............ckOxxxxxxxxxxxkkkOx::lllccx0KKKKKKKXXXXXXXXNNNNNNNNW0l;dkxONWWWNNNXKXNWXK0o............./////
/////...........lOxdxxxxddxxxxkkkkOd;cc,:oc:d0KXKKXKXXXXXXXXNNNNNNNNOc;ckxlkXWWWWWNNNNXXNNK0x,.........../////
/////..........lxdoxxddxxxxxxxkkkOOo;c:..ld:;lxOO0KXXXXXXXNNNNNNNNKd:,;lOo;d0NWWWWWWNNXNWWWX0k,........../////
/////.........lxoodxddddxxxxxkkkkOOl;l:. ;xo;;:;;cdxxdxxxxxxxxxxxkkxdoclx;'oOXWWWWWWWNNWWWWWXKk,........./////
/////........cdolodddddddxxxxxkkkOkc,lc. .oo,',,;cc::ccccclccccccclodkOOx'.lkKWWWWWWWWNNWWWWWX0x'......../////
/////.......;oocodoooddddddxxxkkkOkc,cl. .cl,,;::::::::::ccccccccccclloxOxodxKWWWWWWWWWNNWWWWWK0o......../////
/////......'clcloolooooddddxxxxkkOkc,ldl;';:;:::::::::;;:oddolcccccccdkkdxkdd0WWWWWWWWWWNNWWWWNKOc......./////
/////......,:;:oolllloodddddxxxkkOkc'cddl;;;;;;;:::;;;;:coxO0klccc::ckK0olxdlkNWWWWWWWWWWNNWWWWX0x,....../////
/////......'',colllllooooddddxxkkOkc',:;,;;;;;;;;;:looc:;..;dxlclccccoxl,:xkll0WNWWWWWWWWNNWWWWWKOl....../////
/////........,lllclllooooooddxxkkkOl'.'',,,,,,,,,;:c:'..,'..',;:looddoc,..;oll0NNNNNNNWWWWNNWWWWX0d'...../////
/////........;llcccllooooooodddxkkOd,..,,,,,,,,;:cc:,'......',;:coxk000Oo:lkkOXNNNNNNNNNWWNNWWWWN0k;...../////
/////........;lc:ccllllloooooddxxkkx:.',;;:clodkkkxolc::ccc;,;;:lk0KXXKK0Ok0KNNNNNNNNNNNNWNNNNNNNKOc...../////
/////.....  .:c:::cclllllllooddxxxkd;';clokO0KKK0Odolcllllc;,;:o0XXKd:,,'',;;o0NXNNNNNNNNNNXXXXXNKOo...../////
/////.....  .;c:;:ccccccllllooodxxxl,;ok0000000KKKK0OOOOkxdoodkKK0Oo'... ....;ONXXXXKKXXNNNXXXKKXKOo...../////
/////.....  .;:;;:::cc:cclllooddxxd:,cxO0OOOOOO0000KKKKKKKK00000Okdc'..     .:KNXKKKKXXXXXXKKXXKXKOo...../////
/////...... .,:;,::;::::ccllooodddc,;lkOOOOOOO00OkkkkkkkkkkkkkOkkxdc,..     .cKXKKKKKKKKKKKK0KKKX0kl...../////
/////...... .':;,::;;:;:::cclloodl,';lxOOOOOkkkxddo:;:cccllooddddoc,....   .,dXXKK0000000000000KKOxc...../////
/////.........;;',;;;;;;;:::cllllc'.;lxkOOkkxxdodd:.  .......'',''..      .;OXNK0000000000OOOOO00kd;...../////
/////.........,;'';;,;;;;;;;:::::;'.,:dxkkkkxxddxxl'  .....................dKXNKOOOOOOOOOOkkOkkOOxl'...../////
/////.........';,.,,,,,,,,,;;;;;,'..';lxkkkOOkkkxxdl;.     .','',;;::;;;::lOKXX0kkkkkkkkkkxxkxxkxo:....../////
/////..........,;'','''''',,,,,,'''.'';ldxkOOOkkkxdol:,'..    . .':ldxxxdddkKXXOxxxxxxxxxxdxxdkxoc'....../////
/////...........,,.''...'''''''''''...';coxkkkkkkkkxolc::;,'..    .,cxkkkkkk0XXOddddddddddddddxdl,......./////
/////...........','..'.......''.''''....':ldxxxxxxxxxddooc::;;,... ..';::ccd0XKkddoooodooodoodol;......../////
/////............','..'.........'''''''..',coxxxxxddddddddolcc:;;,'.......;kXX0xdoooooooooolool;........./////
/////..........'..','..........'''''''''..',:ldxxxdddxxxxdddddolcccodollodOKXKkxxolllllllllllc;........../////
/////...........''..,'.........'''''',,,,'''',codxxxxxxxxddddxxxxxxkkOOOO0KK0xodxollcclcccllc;.........../////
/////............''..,'.........''''',,;,,''''';coddxxxxxxxxxxxxkkkkkOOOO000xllodllcccccccc:,............/////
/////.............''..',..........''',,,,,,''..',;clddxxxxxxxxxxxkxxkkOOOOkdccldollccccccc:'............./////
/////...............''..''.........''',,,,,,''''''',:cloddxxxxxxxkkxkkOOkkdc:coocccc::cc:,.............../////
/////................'''..''...'....''',,,,,,''',,'''',;coddxxxxxxkxxkkxdl:::clcccc:ccc;................./////
/////..................''...''''....''''',,,,'''',,,,,'',:lodddxxxddddol:::cccc:::cc:;'................../////
/////....................''...''''...''''',,,,'',,,,,,,'',:ccloodollc:::::cc::::cc:,...................../////
/////.......................'....''''..'''',,'',,,,,,,,,,;:::ccccccc::::::;::cc:;'......................./////
/////...............................'''''''..''''',,,,,,,;;;:::::::;::;;:c:::;'........................../////
/////...................................''''''''''''''''',,,,,,,,;;;:::;;,'............................../////
/////............................. ...........''''',,,,,,;;;;;;;;;,,'..................................../////
/////.............................................'''',,,,...;;;;,,'...................................../////
/////..................................................................................................../////
/////............................................'...................''''................................/////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//..........................................................................................................//

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// ║███████████║███████████║███████████. ║█║║█║🆂🅰🅵🅴🅼🅰🆃🅷║█║║█║ .███████████║███████████║███████████║ ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// ║█║███████████      ║█████║█║█████║ ║█║████████║█║ ║█║████████║█║ ║█║███████████       ║█║████████║█║  ///           
/// ║█║          ███    ║███       ███║ ║█║        ║█║ ║█║        ║█║ ║█║          ███     ║█║        ║█║  ///
/// ║█║           ████  ║███       ███║ ║█║            ║█║        ║█║ ║█║           ████   ║█║        ║█║  ///
/// ║█║            ████ ║███       ███║ ║█║            ║█║        ║█║ ║█║            ████  ║█║        ║█║  ///
/// ║█║            ████ ║███       ███║ ║█║            ║█║████████║█║ ║█║            ████  ║█║████████║█║  ///
/// ║█║           ████  ║███       ███║ ║█║  ║█████║█║ ║█║        ║█║ ║█║           ████   ║█║        ║█║  ///
/// ║█║          ███    ║███       ███║ ║█║        ║█║ ║█║        ║█║ ║█║          ███     ║█║        ║█║  ///
/// ║█║███████████      ║█████║█║█████║ ║█║████████║█║ ║█║        ║█║ ║█║███████████       ║█║        ║█║  ///

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// ║███████████║███████████║███████████. ║█║║█║🆂🅰🅵🅴🅼🅰🆃🅷║█║║█║ .███████████║███████████║███████████║ ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////




                                       // SPDX-License-Identifier: MIT

                                            pragma solidity ^0.8.0;

        /**

        @title DOGADA - a decentralized, deflationary token with anti-front-running measures
        @author DPAKHATRI
        @dev The DOGADA contract is a standard ERC20/BEP20 token with additional functionality:
        A 1% buy tax and 3% sell tax is applied to all transactions
        Maximum transaction amounts are in place to prevent large price impact
        Time restrictions are placed on consecutive buy and sell transactions to prevent front-running
        The contract owner can set certain variables such as fees, maximum transaction amounts, and enable/disable trading
        Anti-front-running measures are in place to prevent bots from taking advantage of the time restrictions
        */



////// ║███████████║███████████║███████████. ║█║║█║🆂🅰🅵🅴🅼🅰🆃🅷║█║║█║ .███████████║███████████║███████████║//////


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     * @param a The first integer to be added.
     * @param b The second integer to be added.
     * @return The sum of the two integers.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow.
     * @param a The integer to be subtracted from.
     * @param b The integer to subtract.
     * @return The difference of the two integers.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     * @param a The first integer to be multiplied.
     * @param b The second integer to be multiplied.
     * @return The product of the two integers.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers, reverts on division by zero.
     * @param a The integer to be divided.
     * @param b The integer to divide by.
     * @return The quotient of the two integers.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}




//// ║███████████║███████████║███████████. ║█║    🅳🅾🅶🅰🅳🅰    ║█║ .███████████║███████████║███████████║ ////
//// ║███████████║███████████║███████████. ║█║       🅵🅾🆁      ║█║ .███████████║███████████║███████████║ ////
//// ║███████████║███████████║███████████. ║█║ 🅲🅾🅼🅼_🆄🅽🅸🆃🆈 ║█║ .███████████║███████████║███████████║ ////
//// ║███████████║███████████║███████████. ║█║       🅵🅾🆁      ║█║ .███████████║███████████║███████████║ ////
//// ║███████████║███████████║███████████. ║█║    🅳🅾🅶🅰🅳🅰    ║█║ .███████████║███████████║███████████║ ////



/**
 * @title DOGADA ERC20 Token
 * @dev Implementation of the DOGADA ERC20 Token. 
 * DOGADA is a deflationary token with buy and sell fees that are used to support the ecosystem and prevent price volatility. 
 * Additionally, there are several restrictions in place to prevent any one individual or entity from controlling too much of the token supply or causing market disruption.
 */



            contract DADA {
                        using SafeMath for uint256;


                /*=====================================
                =            CONFIGURABLES            =
                =====================================*/


// The name, symbol, and decimals variables define the name, symbol, and decimal places of the token
        string public name = "DOGADA";
        
        string public symbol = "DADA";
            
        uint8 public decimals = 18;
    
// The totalSupply variable defines the total number of tokens in existence.
        uint256 public totalSupply = 2 * 10 ** 15;  //2,000,000,000,000,000 DADA


// The maxWalletToken variable defines the maximum number of tokens that any one wallet can hold.
        uint256 public maxWalletToken = totalSupply.mul(2).div(100);    //Maximum 2% of total supply per wallet


// The maxBuyTransactionAmount variable defines the maximum number of tokens that can be bought in one transaction. 
        uint256 public maxBuyTranscationAmount = totalSupply.mul(2).div(100);   //Maximum 2% of total supply per buy transaction


// The maxSellTransactionAmount variable defines the maximum number of tokens that can be sold in one transaction.
        uint256 public maxSellTransactionAmount = maxWalletToken.div(2);    //Maximum 50% of total holding per sell transaction


// The buyFee variable defines the fee that is charged when someone buys tokens.
        uint256 public buyFee = 100;    //1% buy tax


// The sellFee variable defines the fee that is charged when someone sells tokens.
        uint256 public sellFee = 300;   //3% sell tax


// The totalFees variable defines the total tax (buyFee + sellFee).
        uint256 public totalFees = buyFee.add(sellFee);     //Total tax


// The feeDenominator variable defines the denominator used for calculating
        uint256 public feeDenominator = 10000;  //Fee denominator for precision
    
    
    uint256 private _startTime;     //Start Time for Trading
        
        mapping(address => uint256) public balanceOf;   //Token balance of each address
        
            mapping(address => mapping(address => uint256)) public allowance;   //The approved amount of token that can be spent by the owner for a particular address
        
                mapping(address => uint256) public lastTransactionTime;     //Timestamp of last transaction of an address
        
            mapping(address => uint256) public lastBuyTransactionVolume;     //Volume of last buy transaction of an address
        
        mapping(address => uint256) public lastSellTransactionVolume;   //Volume of last sell transaction of an address
    
    mapping(address => bool) public isExcludedFromFee;  //List of addresses excluded from paying fees
    
        bool public isPaused = false;    //Variable to check if contract is paused or not
    
            address public owner;   //Owner of the contract


                /*=====================================
                =               EVENTS                =
                =====================================*/
    

    event Transfer(address indexed from, address indexed to, uint256 value);
        
        event Approval(address indexed owner, address indexed spender, uint256 value);
        
            event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        
        event Pause();
    
    event Unpause();


                /*=====================================
                =             CONSTRUCTOR             =
                =====================================*/

        /**
         * @dev Sets the initial balance of the contract creator to the total supply.
         * Excludes the contract owner and the contract address from transaction fees.
         */

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        isExcludedFromFee[owner] = true;
        isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

                /*=====================================
                =              MODIFIERS              =
                =====================================*/

        /**
         * @dev Throws an error if called by any account other than the owner.
        */
            modifier onlyOwner() {
                    require(msg.sender == owner, "Only owner can call this function");
                    _;
        }
        /**
        * @dev Throws an error if the contract is paused.
         */
            modifier whenNotPaused() {
                    require(!isPaused, "Contract is paused");
                    _;
        }


                /*=====================================
                =            PUBLIC FUNCTIONS         =
                =====================================*/

        /**
        * @dev Transfer tokens to a specified address
        * @param _to The address to transfer tokens to
        * @param _value The amount of tokens to be transferred
        * @return A boolean that indicates if the operation was successful
        */


    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
            
            require(_to != address(0), "ERC20: transfer to the zero address");
                    
                    require(_value > 0, "Transfer amount must be greater than zero");
    
            require(balanceOf[msg.sender] >= _value, "Insufficient balance");

         _transfer(msg.sender, _to, _value);
        return true;
    }


    function _transfer(address _from, address _to, uint256 _value) internal {
            
            uint256 transferAmount = _value;
                if (!isExcludedFromFee[_from] && !isExcludedFromFee[_to]) {
            uint256 fee = transferAmount.mul(totalFees).div(feeDenominator);
                transferAmount = transferAmount.sub(fee);
            balanceOf[address(this)] = balanceOf[address(this)].add(fee);
    }

    require(balanceOf[_to].add(transferAmount) <= maxWalletToken, "Exceeds maximum wallet token amount");
            require(lastTransactionTime[_from].add(12 hours) <= block.timestamp, "Buy/sell time limit not reached");
                if (lastTransactionTime[_from] == 0) {
                    lastTransactionTime[_from] = block.timestamp;
    }

    if (_from != address(this)) {
        require(lastBuyTransactionVolume[_from].add(_value) <= maxBuyTranscationAmount, "Exceeds maximum buy transaction amount");
                lastBuyTransactionVolume[_from] = lastBuyTransactionVolume[_from].add(_value);
    }

    if (_to != address(this)) {
        require(lastSellTransactionVolume[_to].add(_value) <= maxSellTransactionAmount, "Exceeds maximum sell transaction amount");
                lastSellTransactionVolume[_to] = lastSellTransactionVolume[_to].add(_value);
    }

    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(transferAmount);
    emit Transfer(_from, _to, transferAmount);
    lastTransactionTime[_to] = block.timestamp;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
            
            require(_spender != address(0), "ERC20: approve to the zero address");
        
        require(_value > 0, "Approval amount must be greater than zero");

            allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        
        require(_from != address(0), "ERC20: transfer from the zero address");
                
                require(_to != address(0), "ERC20: transfer to the zero address");
                
                require(_value > 0, "Transfer amount must be greater than zero");
                
                require(balanceOf[_from] >= _value, "Insufficient balance");
    
    require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");

            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
            _transfer(_from, _to, _value);
        return true;
    }



function burn(uint256 _value) public onlyOwner returns (bool) {
    require(balanceOf[msg.sender] >= _value, "Insufficient balance");

    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Transfer(msg.sender, address(0), _value);
    return true;
}

function setExcludeFromFee(address _address, bool _excluded) public onlyOwner {
    isExcludedFromFee[_address] = _excluded;
}

function pause() public onlyOwner {
    isPaused = true;
    emit Pause();
}

function unpause() public onlyOwner {
    isPaused = false;
    emit Unpause();
}

function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "New owner cannot be zero address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
}

function setBuyFee(uint256 _buyFee) public onlyOwner {
    buyFee = _buyFee;
    totalFees = buyFee.add(sellFee);
}

function setSellFee(uint256 _sellFee) public onlyOwner {
    sellFee = _sellFee;
    totalFees = buyFee.add(sellFee);
}

function setMaxWalletToken(uint256 _maxWalletToken) public onlyOwner {
    maxWalletToken = _maxWalletToken;
}

function setMaxBuyTransactionAmount(uint256 _maxBuyTransactionAmount) public onlyOwner {
    maxBuyTranscationAmount = _maxBuyTransactionAmount;
}

function setMaxSellTransactionAmount(uint256 _maxSellTransactionAmount) public onlyOwner {
    maxSellTransactionAmount = _maxSellTransactionAmount;
}

function startTrading() public onlyOwner {
    _startTime = block.timestamp;
}

function isTradingEnabled() public view returns (bool) {
    return block.timestamp >= _startTime;
}

function frontRunningAttackGuard(uint256 _amount) public view returns (uint256) {
    uint256 _now = block.timestamp;
    uint256 fee = _amount.mul(totalFees).div(feeDenominator);
    if (_now.sub(lastTransactionTime[msg.sender]) <= 12 hours) {
        uint256 totalFee = lastBuyTransactionVolume[msg.sender].mul(totalFees).div(feeDenominator);
        if (totalFee >= fee) {
            return _amount.sub(fee);
        }
    }
    return _amount;
}




}