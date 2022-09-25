/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
// a contract Web3PaymentSystemContract, courtesy of W3PAY (https://github.com/W3PAY)
pragma solidity >=0.8.17;

// a interface IERC20, courtesy of OpenZeppelin (https://github.com/OpenZeppelin)

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// a interface IUniswapV2Router01, courtesy of Uniswap (https://github.com/Uniswap)

interface IUniswapV2Router01 {
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
}

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
   // +
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    // -
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // -
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    // *
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    // /
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

   // /
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// a contract Web3PaymentSystemContract, courtesy of W3PAY (https://github.com/W3PAY)

// The method allows you to transfer tokens or Eth from one wallet to another with automatic conversion.
// The recipient specifies the desired token and quantity.
// The sender may use a different token.
// On transmission, the sender's token is converted into the recipient's token.
// The sender receives Cashback from the transfer in a network token or project token.
// Recipient can use input paymentInfo field to generate a backend signature for all transmitted data for subsequent verification.
//
// Community working over the development of this project.
// The community develops ready-made solutions for accepting payments on websites and much more.
// Read more here https://github.com/W3PAY

contract Web3PaymentSystemContract {
    receive() external payable {}
    fallback() external payable {}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) RecipientTokensArr;
    mapping(address=>bool) SenderTokensArr;
    mapping(address=>bool) SwapRouterContractsArr;
    mapping(address=>uint8) AllowedRecipients;

    address private _owner;
    address private _cashbackToken;
    uint8 private _cashbackPercent = 1; // 1%
    uint256 private _priceRemoveAllowedRecipient = 10000000000000000; // 0.01
    uint256 private _priceAddAllowedRecipient = 10000000000000000; // 0.01

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        // BNB Smart Chain (BEP20) - Testnet default settings
        _cashbackToken = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd); // BNB
        SwapRouterContractsArr[address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)] = true; // PancakeSwap

        RecipientTokensArr[address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)] = true; // WETH
        RecipientTokensArr[address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7)] = true; // BUSD
        RecipientTokensArr[address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684)] = true; // USDT
        RecipientTokensArr[address(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca)] = true; // ETH
        RecipientTokensArr[address(0x8a9424745056Eb399FD19a0EC26A14316684e274)] = true; // DAI

        SenderTokensArr[address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)] = true; // WETH
        SenderTokensArr[address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7)] = true; // BUSD
        SenderTokensArr[address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684)] = true; // USDT
        SenderTokensArr[address(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca)] = true; // ETH
        SenderTokensArr[address(0x8a9424745056Eb399FD19a0EC26A14316684e274)] = true; // DAI
    }

    // get address Cashback Token
    function getCashbackToken() public view returns (address) {
        return _cashbackToken;
    }

    // change Cashback Token
    function changeCashbackToken(address setCashbackToken) public {
        require(_owner == msg.sender, "caller is not the owner");
        _cashbackToken = setCashbackToken;
    }

    // get address owner
    function owner() public view returns (address) {
        return _owner;
    }

    // get address owner
    function getOwner() external view returns (address) {
        return owner();
    }

    // transfer Ownership
    function _transferOwnership(address newOwner) internal {
        require(_owner == msg.sender, "caller is not the owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    // transfer Ownership
    function transferOwnership(address newOwner) public {
        _transferOwnership(newOwner);
    }

    //require(RecipientTokensArr[addressRecipientToken], "Recipient Token not allowed");

    // add Recipient Token
    function addRecipientToken(address addressToken) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(!RecipientTokensArr[addressToken], "address already listed");
        RecipientTokensArr[addressToken] = true;
    }


    // remove Recipient Token
    function removeRecipientToken(address addressToken) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(RecipientTokensArr[addressToken], "address not already listed");
        RecipientTokensArr[addressToken] = false;
    }

    // check Recipient Token
    function checkRecipientToken(address addressToken) external view returns (bool) {
        return RecipientTokensArr[addressToken];
    }

    //require(SenderTokensArr[addressSenderToken], "Sender Token not allowed");

    // add Sender Token
    function addSenderToken(address addressToken) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(!SenderTokensArr[addressToken], "address already listed");
        SenderTokensArr[addressToken] = true;
    }

    // remove Sender Token
    function removeSenderToken(address addressToken) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(SenderTokensArr[addressToken], "address not already listed");
        SenderTokensArr[addressToken] = false;
    }

    // check Sender Token
    function checkSenderToken(address addressToken) external view returns (bool) {
        return SenderTokensArr[addressToken];
    }

    //require(SwapRouterContractsArr[addressSwapRouter], "SwapRouter Token not allowed");

    // add SwapRouter Contract
    function addSwapRouterContract(address addressContract) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(!SwapRouterContractsArr[addressContract], "address already listed");
        SwapRouterContractsArr[addressContract] = true;
    }

    // remove SwapRouter Contract
    function removeSwapRouterContract(address addressContract) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(SwapRouterContractsArr[addressContract], "address not already listed");
        SwapRouterContractsArr[addressContract] = false;
    }

    // check SwapRouter Contract
    function checkSwapRouterContract(address addressContract) external view returns (bool) {
        return SwapRouterContractsArr[addressContract];
    }

    //require(AllowedRecipients[addressRecipient] == 0, "addressRecipient not allowed");

    // Anyone can pay and block the address for receiving.
    // The recipient will not be able to accept new payments.
    // If the recipient changes wallet or use function addAllowedRecipient, they can continue to receive transfers.
    function removeAllowedRecipientAndCommentText(address addressRecipient, uint8 numberStatus, string calldata CommentText) payable public {
        require(msg.value >= _priceRemoveAllowedRecipient, "msg.value < priceRemoveAllowedRecipient");
        require(AllowedRecipients[addressRecipient] == 0, "AllowedRecipient != 0");
        AllowedRecipients[addressRecipient] = numberStatus;
    }

    // activate address Recipient
    function addAllowedRecipient(address addressRecipient) payable public {
        require(msg.value >= _priceAddAllowedRecipient, "msg.value < priceAddAllowedRecipient");
        require(AllowedRecipients[addressRecipient] != 0, "AllowedRecipient = 0");
        AllowedRecipients[addressRecipient] = 0;
    }

    // set Allowed Recipient.
    function setAllowedRecipient(address addressRecipient, uint8 numberStatus) public {
        require(_owner == msg.sender, "caller is not the owner");
        AllowedRecipients[addressRecipient] = numberStatus;
    }

    // Check recipient address Allowed. 0 - allowed, 1 or more - not allowed
    function checkAllowedRecipient(address addressRecipient) external view returns (uint8) {
        return AllowedRecipients[addressRecipient];
    }

    // Get a price to activate a recipient's address
    function getPriceAddAllowedRecipient() public view returns (uint256) {
        return _priceAddAllowedRecipient;
    }

    // Change a price to activate a recipient's address
    function changePriceAddAllowedRecipient(uint256 newPriceAddAllowedRecipient) public {
        require(_owner == msg.sender, "caller is not the owner");
        _priceAddAllowedRecipient = newPriceAddAllowedRecipient;
    }

    // Get a price to block a recipient's address
    function getPriceRemoveAllowedRecipient() public view returns (uint256) {
        return _priceRemoveAllowedRecipient;
    }

    // Change a price to block a recipient's address
    function changePriceRemoveAllowedRecipient(uint256 newPriceRemoveAllowedRecipient) public {
        require(_owner == msg.sender, "caller is not the owner");
        _priceRemoveAllowedRecipient = newPriceRemoveAllowedRecipient;
    }

    // get Receiver's Cashback Percentage
    function getCashbackPercent() public view returns (uint8) {
        return _cashbackPercent;
    }

    // change Receiver's Cashback Percentage
    function changeCashbackPercent(uint8 newCashbackPercent) public {
        require(_owner == msg.sender, "caller is not the owner");
        _cashbackPercent = newCashbackPercent;
    }

    event eventSendRecipientFinish(address addressRecipient, address addressRecipientToken, uint256 amountRecipientToken, address addressSenderToken, uint256 amountSenderToken, address addressSwapRouter, uint256 amountOutMinCashback, string paymentInfo, uint256 amountRefundEth, uint256 amountRefundTokenSender, uint256 percentRecipient, uint256 percentCashback, address addressTokensCashbac);
    event eventSendRecipient(uint256 percentRecipient, address addressRecipient, address addressRecipientToken, uint256 amountRecipientToken, uint256 amountUsedTokensSender, string transferType);
    event eventSendCashbackSender(uint256 percentCashback, address addressRecipientCashback, address addressTokensCashback, uint256 amountTokensCashback, uint256 amountUsedTokensSender, string transferType);
    event eventSendLeftoverTokensSender(address addressToken, uint256 amountTokens);
    event eventSendLeftoverEthSender(uint256 amountEth);

    // addressRecipient - address Recipient.
    // addressRecipientToken - the token in which the recipient wants to receive. For Eth, use the address WETH().
    // amountRecipientToken - the amount the recipient wants to receive.
    // addressSenderToken - the token into which the sender is ready to transfer. For Eth, use the address WETH().
    // amountSenderToken - the maximum amount that the sender is ready to transfer. Excess tokens will be returned to the sender.
    // addressSwapRouter - token conversion contract.
    // amountOutMinCashback - amount of minimum cashback.
    // paymentInfo - Recipient can use this field to generate a backend signature for all transmitted data for subsequent verification.
    //
    // Important!
    // If addressSenderToken == address WETH(), then payableAmount must be equal to amountSenderToken.
    // If addressSenderToken == addressRecipientToken then amountSenderToken must be equal to amountRecipientToken.
    // If addressSenderToken != address WETH(), then approve must be executed before calling the function sendRecipient.
    // Approve is executed in the addressSenderToken contract. spender == address current contract, amount > amountSenderToken.
    function W3PAYMethod(
        address addressRecipient,
        address addressRecipientToken,
        uint256 amountRecipientToken,
        address addressSenderToken,
        uint256 amountSenderToken,
        address addressSwapRouter,
        uint256 amountOutMinCashback,
        string calldata paymentInfo
    ) payable public {
        require(RecipientTokensArr[addressRecipientToken], "Recipient Token not allowed");
        require(SenderTokensArr[addressSenderToken], "Sender Token not allowed");
        require(SwapRouterContractsArr[addressSwapRouter], "SwapRouter Token not allowed");
        require(AllowedRecipients[addressRecipient] == 0, "addressRecipient not allowed. Use function addAllowedRecipient.");

        address[] memory addressArr = new address[](4);
        addressArr[0] = addressRecipient;
        addressArr[1] = addressRecipientToken;
        addressArr[2] = addressSenderToken;
        addressArr[3] = addressSwapRouter;

        uint256[] memory amountArr = new uint256[](3);
        amountArr[0] = amountRecipientToken;
        amountArr[1] = amountSenderToken;
        amountArr[2] = amountOutMinCashback;

        string[] memory textArr = new string[](1);
        textArr[0] = paymentInfo;

        uint256[] memory amountRefundArr = new uint256[](2);
        amountRefundArr[0] = msg.value; //refund ETH
        amountRefundArr[1] = amountSenderToken; //refund Tokens

        IERC20 contractTokenSender = IERC20(addressArr[2]);
        IUniswapV2Router01 contractRouter01 = IUniswapV2Router01(addressArr[3]);

        require(amountArr[1] > 0, "You need to sell at least some tokens");

        if(contractRouter01.WETH()==addressArr[2]){
            require(amountArr[1] == msg.value, "amountSenderToken != payableAmount");
            amountRefundArr[1] = 0;
        } else {
            require(contractTokenSender.approve(addressArr[3], amountArr[1]), 'approve failed.');
            require(contractTokenSender.transferFrom(msg.sender, address(this), amountArr[1]), 'transferFrom failed.');
            // Approve spend the token this contract
            uint256 allowanceT = contractTokenSender.allowance(msg.sender, address(this));
            //require(allowanceT >= amountArr[1], "Check the token allowance");
        }

        uint256[] memory amountGeneratedArr = new uint256[](6);

        uint256 sendPercent = SafeMath.sub(100, _cashbackPercent); // 100 - _cashbackPercent

        // 1%
        amountGeneratedArr[0] = SafeMath.div(amountArr[1], 100); // 1% TokenSender
        amountGeneratedArr[1] = SafeMath.div(amountArr[0], 100); // 1% TokenRecipient

        // (100 - _cashbackPercent)% send Recipient
        amountGeneratedArr[2] = SafeMath.mul(amountGeneratedArr[0], sendPercent); // (100 - _cashbackPercent)% TokenSender
        amountGeneratedArr[3] = SafeMath.mul(amountGeneratedArr[1], sendPercent); // (100 - _cashbackPercent)% TokenRecipient

        if(amountGeneratedArr[2] > amountArr[1]){ amountGeneratedArr[2] = amountArr[1]; }
        if(amountGeneratedArr[3] > amountArr[0]){ amountGeneratedArr[3] = amountArr[0]; }

        // _cashbackPercent send Sender
        amountGeneratedArr[4] = SafeMath.mul(amountGeneratedArr[0], _cashbackPercent); // amountSenderToken - (1% * _cashbackPercent)% TokenSender
        if(amountGeneratedArr[4] > amountArr[1]){ amountGeneratedArr[4] = amountArr[1]; }

        // 99% send Recipient
        if(amountGeneratedArr[3] > 0){
            if (addressArr[1] == addressArr[2]) {
                require(amountArr[0] == amountArr[1], "amountRecipientToken != amountSenderToken");
                if(contractRouter01.WETH()==addressArr[2]){
                    payable(addressArr[0]).transfer(amountGeneratedArr[3]);
                    amountRefundArr[0] = SafeMath.sub(amountRefundArr[0], amountGeneratedArr[3]);
                    //emit eventSendRecipient(sendPercent, addressArr[0], addressArr[1], amountGeneratedArr[3], amountGeneratedArr[2], "payable.transfer");
                } else {
                    contractTokenSender.transfer(addressArr[0], amountGeneratedArr[3]);
                    amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amountGeneratedArr[3]);
                    //emit eventSendRecipient(sendPercent, addressArr[0], addressArr[1], amountGeneratedArr[3], amountGeneratedArr[2], "token.transfer");
                }
            } else {
                if(contractRouter01.WETH()==addressArr[2]){
                    address[] memory path = new address[](2);
                    path[0] = contractRouter01.WETH();
                    path[1] = addressArr[1];
                    uint[] memory amounts = contractRouter01.swapETHForExactTokens{ value: amountGeneratedArr[2] }(amountGeneratedArr[3], path, addressArr[0], block.timestamp);
                    amountRefundArr[0] = SafeMath.sub(amountRefundArr[0], amounts[0]);
                    //emit eventSendRecipient(sendPercent, addressArr[0], addressArr[1], amountGeneratedArr[3], amounts[0], "swapETHForExactTokens");
                } else if (contractRouter01.WETH()==addressArr[1]){
                    address[] memory path = new address[](2);
                    path[0] = addressArr[2];
                    path[1] = contractRouter01.WETH();
                    uint[] memory amounts = contractRouter01.swapTokensForExactETH(amountGeneratedArr[3], amountGeneratedArr[2], path, addressArr[0], block.timestamp);
                    amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
                    //emit eventSendRecipient(sendPercent, addressArr[0], addressArr[1], amountGeneratedArr[3], amounts[0], "swapTokensForExactETH");
                } else {
                    address[] memory path = new address[](3);
                    path[0] = addressArr[2];
                    path[1] = contractRouter01.WETH();
                    path[2] = addressArr[1];
                    uint[] memory amounts = contractRouter01.swapTokensForExactTokens(amountGeneratedArr[3], amountGeneratedArr[2], path, addressArr[0], block.timestamp);
                    amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
                    //emit eventSendRecipient(sendPercent, addressArr[0], addressArr[1], amountGeneratedArr[3], amounts[0], "swapTokensForExactTokens");
                }
            }
        }

        //send cashback - buy network tokens or project and send them to the Sender
        if (_cashbackToken != addressArr[2] && amountGeneratedArr[4] > 0) {
            if(contractRouter01.WETH()==addressArr[2]){
                address[] memory path = new address[](2);
                path[0] = contractRouter01.WETH();
                path[1] = _cashbackToken;
                uint[] memory amounts = contractRouter01.swapExactETHForTokens{ value: amountGeneratedArr[4] }(amountArr[2], path, msg.sender, block.timestamp);
                amountRefundArr[0] = SafeMath.sub(amountRefundArr[0], amounts[0]);
                //emit eventSendCashbackSender(_cashbackPercent, msg.sender, _cashbackToken, amounts[amounts.length - 1], amounts[0], "swapExactETHForTokens");
            } else if (contractRouter01.WETH()==_cashbackToken){
                address[] memory path = new address[](2);
                path[0] = addressArr[2];
                path[1] = contractRouter01.WETH();
                uint[] memory amounts = contractRouter01.swapExactTokensForETH(amountGeneratedArr[4], amountArr[2], path, msg.sender, block.timestamp);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
                //emit eventSendCashbackSender(_cashbackPercent, msg.sender, _cashbackToken, amounts[amounts.length - 1], amounts[0], "swapExactTokensForETH");
            } else {
                address[] memory path = new address[](3);
                path[0] = addressArr[2];
                path[1] = contractRouter01.WETH();
                path[2] = _cashbackToken;
                uint[] memory amounts = contractRouter01.swapExactTokensForTokens(amountGeneratedArr[4], amountArr[2], path, msg.sender, block.timestamp);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
                //emit eventSendCashbackSender(_cashbackPercent, msg.sender, _cashbackToken, amounts[amounts.length - 1], amounts[0], "swapExactTokensForTokens");
            }
        }

        uint256 BalanceTokenMax = contractTokenSender.balanceOf(address(this));

        // refund leftover Tokens to addressSenderToken
        if(contractRouter01.WETH()!=addressArr[2]){
            if(BalanceTokenMax < amountRefundArr[1]){
                amountRefundArr[1] = BalanceTokenMax;
            }
            if(amountRefundArr[1]>0){
                contractTokenSender.transfer(msg.sender, amountRefundArr[1]);
                //emit eventSendLeftoverTokensSender(addressArr[2], amountRefundArr[1]);
            }
        }

        // refund leftover ETH to addressSenderToken
        if(address(this).balance < amountRefundArr[0]){
            amountRefundArr[0] = address(this).balance;
        }
        if(amountRefundArr[0]>0){
            (bool success, ) = msg.sender.call{value:amountRefundArr[0]}("");
            require(success, "Transfer failed.");
            //emit eventSendLeftoverEthSender(amountRefundArr[0]);
        }

        //emit eventSendRecipientFinish(addressArr[0], addressArr[1], amountArr[0], addressArr[2], amountArr[1], addressArr[3], amountArr[2], textArr[0], amountRefundArr[0], amountRefundArr[1], sendPercent, CashbackPercent, _cashbackToken);
    }

    // transfer Tokens
    function contractTokensTransfer(address _token, address _to, uint256 _amount) external {
        require(_owner == msg.sender, "caller is not the owner");
        IERC20 contractToken = IERC20(_token);
        contractToken.transfer(_to, _amount);
    }

    // transfer Eth
    function contractEthTransfer(address _to, uint256 _amount) external {
        require(_owner == msg.sender, "caller is not the owner");
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

}