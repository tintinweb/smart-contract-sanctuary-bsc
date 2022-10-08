/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// this contract should be deployed after the deployment of the two contracts tokenUSD and tokenJED
// as instrcuted in the 2_deploy_contracts file




interface IERC20Uniswap {
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


contract TokenSwap {
    address payable admin;
    //ratioAX is the percentage of how much TokenA is worth of TokenX
    uint256 ratioAX;
    bool AcheaperthenX;
    uint256 fees;
   IERC20Uniswap tokenUSD;
   IERC20Uniswap tokenJED;

uint base = 1_000_000;


uint public reserveUSD ;
uint public reserverJe ;


    constructor(address _tokenUSD, address _tokenJED, uint tokenUSDreserve, uint tokenJEDreserve) {
        admin = payable(msg.sender);
        tokenUSD = IERC20Uniswap(_tokenUSD);

      tokenJED = IERC20Uniswap(_tokenJED);

      reserverJe = tokenJEDreserve;
      reserveUSD = tokenUSDreserve;
        //due to openzeppelin implementation, transferFrom function implementation expects _msgSender() to be the beneficiary from the caller
        // but in this use cae we are using this contract to transfer so its always checking the allowance of SELF
        tokenUSD.approve(address(this), tokenUSD.totalSupply());
        tokenJED.approve(address(this), tokenUSD.totalSupply());
    }

    modifier onlyAdmin() {
        payable(msg.sender) == admin;
        _;
    }

    function setRatio(uint256 _ratio) public onlyAdmin {
        ratioAX = _ratio;
    }

    function getRatio() public view onlyAdmin returns (uint256) {
        return ratioAX;
    }

    function setFees(uint256 _Fees) public onlyAdmin {
        fees = _Fees;
    }

    function getFees() public view onlyAdmin returns (uint256) {
        return fees;
    }

    // accepts amount of tokenUSD and exchenge it for tokenJED, vice versa with function swapTKX
    // transfer tokensABC from sender to smart contract after the user has approved the smart contract to
    // withdraw amount TKA from his account, this is a better solution since it is more open and gives the
    // control to the user over what calls are transfered instead of inspecting the smart contract
    // approve the caller to transfer one time from the smart contract address to his address
    // transfer the exchanged tokenJED to the sender
    function swapUSD(uint256 amountUSD) public returns (uint256) {
        //check if amount given is not 0
        // check if current contract has the necessary amout of Tokens to exchange
        require(amountUSD > 0, "amountUSD must be greater then zero");
        require(
            tokenUSD.balanceOf(msg.sender) >= amountUSD,
            "sender doesn't have enough Tokens"
        );

   
    uint256 refinal = reserveUSD + amountUSD;
    
    uint finala = (reserverJe*base)/(reserveUSD);

    uint finalbtotransfer = ((finala*amountUSD)/base)/1e12;
    uint finalb = ((finala*amountUSD)/base);
    uint jefinal = reserverJe - finalb;

   


        require(
            tokenJED.balanceOf(address(this)) > amountUSD,
            "currently the exchange doesnt have enough XYZ Tokens, please retry later :=("
        );

        tokenUSD.transferFrom(msg.sender, address(this), amountUSD);
     
        tokenJED.transfer(
        
            address(msg.sender),
            finalbtotransfer
        );
         reserveUSD = refinal;
       reserverJe = jefinal;
        return finalb;
    }

    //leting the Admin of the TokenSwap to buyTokens manually is preferable and better then letting the contract
    // buy automatically tokens since contracts are immutable and in case the value of some tokens beomes
    // worthless its better to not to do any exchange at all
   
    function swapJED(uint256 amountJED) public returns (uint256) {
        //check if amount given is not 0
        // check if current contract has the necessary amout of Tokens to exchange
        require(amountJED > 0, "amountUSD must be greater then zero");
        require(
            tokenJED.balanceOf(msg.sender) >= amountJED,
            "sender doesn't have enough Tokens"
        );

   
    uint256 refinal = reserverJe + amountJED;
    
    uint finala = (reserveUSD*1e12*base)/reserverJe;

    uint finalb = ((finala*amountJED)/base)/1e12;

    uint jefinal = reserveUSD - finalb;

   


        require(
            tokenJED.balanceOf(address(this)) > amountJED,
            "currently the exchange doesnt have enough XYZ Tokens, please retry later :=("
        );

        tokenJED.transferFrom(msg.sender, address(this), amountJED);
     
        tokenUSD.transfer(
        
            address(msg.sender),
            finalb
        );
         reserverJe = refinal;
       reserveUSD = jefinal;
        return finalb;
    }


function updateReseaveUSD(uint256 _reserveUSD) public  onlyAdmin returns (uint256) {
       reserveUSD = _reserveUSD ;
       return  reserveUSD;
    }
function updateReseaveJED(uint256 _reserveJED) public  onlyAdmin returns (uint256) {
       reserverJe = _reserveJED ;
       return  reserverJe;
    }
   
}