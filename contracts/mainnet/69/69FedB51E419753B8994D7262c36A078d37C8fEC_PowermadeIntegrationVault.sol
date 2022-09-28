/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *    ███████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
 *    ██╔════╝██╔════╝██╔═══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
 *    █████╗  ██║     ██║   ██║███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
 *    ██╔══╝  ██║     ██║   ██║╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
 *    ███████╗╚██████╗╚██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
 *    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
 *                                                                                  
 */                                                                                                   
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

// Interface of a token BEP20 - ERC20 - TRC20 - .... All functions of the standard interface are declared, even if not used
interface TOKEN20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Interface of the PancakeSwap Router
// Reduced Interface only for the needed functions
interface IPancakeRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

// Interface to access Powermade contract data
interface Powermade {
    // get the owner 
    function ownerWallet() external view returns (address owner);
    // Get the token used by the Affiliation system (BUSD)
    function token_addr() external view returns (address token_address);

}

// Interface of the Powermade Token, that implements also a standard BEP20 interface. Only needed functions are included
interface PowermadeToken is TOKEN20 {
    // Get the pancake router used by the token
    function pancakeRouter() external view returns (address);
}

// Interface to the external Tunnel contract (triggers used to send money to external contract). Only used function is declared
interface TunnelContract {
    // Trigger function used for token transfer + action (must limit gas). userID and packageID can be used to share data about the purchase
    function triggerFunction(address token_addr, uint amount, uint userID, uint16 packageID, string calldata descID) external returns(bool outcome);
}


contract PowermadeIntegrationVault is TunnelContract {

    Powermade public powermadeContract;                         // The PowermadeAffiliation contract
    PowermadeToken public PWDtokenContract;                     // PWD token smart contract
    address public constant address_zero = address(0);          // The address(0)
    mapping(address => bool) public enabled_contracts;          // Contracts enabled to call withdrawToken() function or receive the tunnel (tunnelContract)
    address public tunnelAddress;                               // External address that can be used to redirect a part of the deposited tokens when triggerFunction() is used
    bool public tunnelGenericSC;                                // Set true if the tunnel is a smart contract but not implementing the TunnelContract interface
    bool private entered;                                       // Reentrant protection for tunnel trigger
    uint16 public tunnel_perthousand;                           // Percentage (per-thousand) to be redirected to another address/contract (tunnel) 
    
    event ChangedFeatureParameterEv(string indexed tag);    // Indexed strings are saved as keccak256(string)
    event WithdrawnFromVault(address indexed caller, address indexed token, bool indexed ext_contract, uint amount, address destination);
    event VaultConvertedPWDtoTokenUsed(address indexed caller, address indexed token, uint amount, bool direct, uint initial_PWD, uint remaining_PWD, uint initial_Token, uint final_balance_Token, uint conversion_received_amount);


    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == powermadeContract.ownerWallet(), "Denied");
        _;
    }

    // Modifier to be used with functions that can be called only by The PowermadeAffiliation contract
    modifier onlyPowermadeContract()
    {
        require(msg.sender == address(powermadeContract), "Denied");
        _;
    }

    // Constructor called when deploying
    constructor(address _powermadeAddress, address _PWD_token_address) {
        powermadeContract = Powermade(_powermadeAddress);
        PWDtokenContract = PowermadeToken(_PWD_token_address);
    }


    // Fallback function for methods
    fallback() external {
        revert('FBE');
    }

    // Fallback function for payments
    receive() external payable {
        // Prevent users from using the fallback function to send money
        revert('FBE');
    }


    // First the amount (BUSD) is sent to this contract address(this) and then the trigger is called. descID is "PwdAff" when called from the PowermadeAffiliation
    // When called the money is still in the contract, so we can use also balanceOf(address(this)) - NB: if triggerFunction reverts everything is reverted, the transfer too)
    // In this case the function will be called only by the PowermadeContract so the descID check will not be done.
    function triggerFunction(address token_addr, uint amount, uint userID, uint16 packageID, string calldata) external onlyPowermadeContract returns(bool outcome) {
        // Tunnel chain
        uint tunnel_amount = amount*tunnel_perthousand/1000;
        if (tunnelAddress != address(0)) {
            if (isContract(tunnelAddress) && !tunnelGenericSC) {
                require(enabled_contracts[tunnelAddress], "TCnE");
                ////// SEND money out of the tunnel (with reentrant protection)
                require(!entered, "Reent");
                entered = true;
                // Do the token transfer to the tunnel contract (money will be already there when executing the triggerFunction)
                TOKEN20(token_addr).transfer(tunnelAddress, tunnel_amount); 
                // Call the trigger function
                bool success = TunnelContract(tunnelAddress).triggerFunction(token_addr, tunnel_amount, userID, packageID, "PwdVault");
                require(success, "TCErr");
                entered = false;
            } else {
                TOKEN20(token_addr).transfer(tunnelAddress, tunnel_amount); 
            }    
        }
        return true;
    }


    // Enable or disable the external contracts that can call the withdrawToken() function or receive a tunnel (tunnelContract) with the triggerFunction
    function enableDisableExtContract(address external_contract, bool status) external onlyPowermadeOwner {
        require(external_contract != address(0) && isContract(external_contract), "InvAddr");
        enabled_contracts[external_contract] = status;
        emit ChangedFeatureParameterEv("EnExtSC");
    }


    // Function used to change the Tunnel config. If tunnelAddress is a Smart Contract, it will be called also its triggerFunction() by default. To do not call it,
    // specify the _tunnelGenericSC flag to true. In this case it must be al an enabled contract. If the destination is not a smart contract a transfer will be used. 
    // Disable the tunnel (default) with address(0) or setting the the percentage at 0.
    function changeTunnelConfig(address _tunnelAddress, bool _tunnelGenericSC, uint16 _tunnel_perthousand) public onlyPowermadeOwner {
        if (isContract(_tunnelAddress) && !_tunnelGenericSC) {
            require(enabled_contracts[_tunnelAddress], "TCnE");
        }
        tunnelAddress = _tunnelAddress;
        tunnelGenericSC = _tunnelGenericSC;
        tunnel_perthousand = _tunnel_perthousand;
        if (tunnel_perthousand == 0) {
            tunnelAddress = address(0);
        }
        emit ChangedFeatureParameterEv("Tunnel");
    }


    // Withdraw tokens from the contract. Can be done by Powermade owner or enabled contracts
    function withdrawToken(address token, uint amount, address destination) external {
        // Only powermade owner or enabled smart contracts
        require(msg.sender == powermadeContract.ownerWallet() || enabled_contracts[msg.sender], "Denied");
        bool success = TOKEN20(token).transfer(destination, amount);      // Do the token transfer. The source is the contract itself
        require(success, "T20Err");
        emit WithdrawnFromVault(msg.sender, token, enabled_contracts[msg.sender], amount, destination);
    }


    // Withdraw tokens from the contract. Simplified function, default BUSD withdraw, else PWD if specified
    function withdrawTokenSimpleOwner(bool withdrawPWD, uint amount, bool amount_is_cents, address destination) external onlyPowermadeOwner {
        address token = withdrawPWD ? address(PWDtokenContract) : powermadeContract.token_addr();
        if (!amount_is_cents) {
            amount = amount * 1e18;       // coin_unit = 1e18
        }
        bool success = TOKEN20(token).transfer(destination, amount);      // Do the token transfer. The source is the contract itself
        require(success, "T20Err");
        emit WithdrawnFromVault(msg.sender, token, enabled_contracts[msg.sender], amount, destination);
    }


    // Manual conversion triggered by powermade owner or automatic by enabled smart contracts
    // If direct_pool is true, the direct pool between PWD and BUSD (TokenUsed) will be used, without passing through the WBNB pool
    function convertPWDtoTokenUsed(uint amount, bool direct_pool, bool amount_is_cents) external {
        // Only powermade owner or enabled smart contracts
        require(msg.sender == powermadeContract.ownerWallet() || enabled_contracts[msg.sender], "Denied");
        if (!amount_is_cents) {
            amount = amount * 1e18;       // coin_unit = 1e18
        }
        _convertPWDtoTokenUsed(amount, direct_pool);
    }


    // Function used to preview the received amount before a conversion. It returns the received amount in Wei
    // Can be used to obtain the exchange rate (indicative) passing amount = 1 and amount_is_cents = false 
    function previewConversionReceivedAmount(uint amount, bool direct_pool, bool amount_is_cents) public view returns (uint received_amount) {
        if (!amount_is_cents) {
            amount = amount * 1e18;       // coin_unit = 1e18
        }
        address token_used_affiliation = powermadeContract.token_addr();
        IPancakeRouter pancakeRouter = IPancakeRouter(PWDtokenContract.pancakeRouter());
        address[] memory path;
        if (direct_pool) {
            path = new address[](2);
            path[0] = address(PWDtokenContract);
            path[1] = token_used_affiliation;
            received_amount = pancakeRouter.getAmountsOut(amount, path)[1];
        } else {
            path = new address[](3);
            path[0] = address(PWDtokenContract);
            path[1] = pancakeRouter.WETH();
            path[2] = token_used_affiliation;
            received_amount = pancakeRouter.getAmountsOut(amount, path)[2];
        }    
    }


    // Internal function used for the conversion
    function _convertPWDtoTokenUsed(uint amount, bool direct_pool) private {
        address token_used_affiliation = powermadeContract.token_addr();
        IPancakeRouter pancakeRouter = IPancakeRouter(PWDtokenContract.pancakeRouter());
        address[] memory path;
        if (direct_pool) {
            path = new address[](2);
            path[0] = address(PWDtokenContract);
            path[1] = token_used_affiliation;
        } else {
            path = new address[](3);
            path[0] = address(PWDtokenContract);
            path[1] = pancakeRouter.WETH();
            path[2] = token_used_affiliation;
        }
        PWDtokenContract.approve(address(pancakeRouter), amount);
        uint256 initialBalanceToken = TOKEN20(token_used_affiliation).balanceOf(address(this));
        uint256 initialBalancePWD = PWDtokenContract.balanceOf(address(this));
        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,      // Accept any amount of converted Token
            path,
            address(this),      // Send to the vault
            block.timestamp
        );
        uint256 finalBalanceToken = TOKEN20(token_used_affiliation).balanceOf(address(this));
        uint256 finalBalancePWD = PWDtokenContract.balanceOf(address(this));
        emit VaultConvertedPWDtoTokenUsed(msg.sender, token_used_affiliation, amount, direct_pool, initialBalancePWD, finalBalancePWD, initialBalanceToken, finalBalanceToken, finalBalanceToken-initialBalanceToken);
    }


    // Check if an address is a Smart Contract
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


}