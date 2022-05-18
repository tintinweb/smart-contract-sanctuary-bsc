/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*                                                                                          
                                           ..:^~~!!!!!~~^:.                                         
                                       .:~!7??????????????7!~:.                                     
                                    .^!7??J???7??77777????????7~:        ...::..                    
                                .:~7?JJJJJ?7JYP?^5GPP577J?77????7!?YYYJYY555555Y?!^                 
                     .^~!!777!^~7JJJJJJJJJ~#@@@J~#@@@@&?777Y77?????YB&##BBGGGPPPPP5J~.              
                 .^[email protected]&@&!7&@@@@@[email protected]&5!?J????YB&##BBBBGGPP555J:             
               [email protected]!Y&&&B~Y&@G7#@#77?&&&?7JJJJJ??5B&###BBBGGPP5PY^            
              ~YPPP55YY555JYP#&&&J5BYJ#&[email protected][email protected]@5^G&#77J&&@57JJJJJJJJJ5B####BBBGPP555^           
            .7PPP5YY55PPGJY&&#BPYPG?!55&5~B&JP&Y5&#Y!G&B?JJ&#&G7JYYYYJJJJJJY5GB##BBGGP55Y..         
           .?PPYJY55PPGGBG5PPPGGP5Y!5?J#J7B#[email protected]&#J7B&PY5Y&#5B?PPPP555555555Y55PPGGGPP5P!          
           ?PYJYY5PPGGBBBB##GPP77BJ?B~G#?J##JPP55&#PP#&YGGJ&#7#?B########BBBBBBGGPPP55555J .        
          ^YJJYY5PGP55PPJJYYG&J?&G~BG~B#JY#&##J55&&&&&GJB#J&&[email protected]&#GG#&&&&&&&####BBGGP55Y^.        
        .~?JJYY5P5Y5G&#YG55#@Y7&&J?&G!B#YJB&&&BYYB&&BP#&[email protected]&@[email protected]@@&&&&&#PPPP55GGPP5?:       
       :!JJJYY5YJPB#@BY#[email protected]@[email protected]#[email protected]!B&5YP&&&&5YY&&&[email protected]#J?&@5?P5&@##@@@&@@@&&JG#&&#BY5GGP5Y~      
      :7?JJYY5JY##Y&#J#[email protected]@@75#&[email protected]@B5J#&@[email protected]@@#[email protected]&[email protected]&Y?55&@@@&PPPG&@&5G&@@@@&YPGGP55~     
     ^[email protected]#[email protected]@&#B!#P&[email protected]&5?&@[email protected]@#[email protected]@Y#@@GY5&@#[email protected]&GG#Y#@@&[email protected]#@@BPGBBBPPBBGPP5Y:    
    :[email protected]@[email protected]#J#[email protected]#Y&[email protected]@[email protected]@[email protected]@[email protected]@@BJY&@@[email protected]&@@@&Y#@@BY#&BYG&@@&#BB##BBGGP55!.   
   [email protected][email protected]@@YP&@B?&#YY#@&YJ#@&?5&@G5&[email protected]@[email protected]@[email protected]@&&&@[email protected]@@YG&&&GPPGG#&###BBGGP55!..  
  [email protected]~#@[email protected]@[email protected]@B7#@[email protected]@[email protected]@[email protected]#[email protected]@@@@&[email protected]@#YY#@[email protected]@&[email protected]&&@@&&#YG##BBGGPP55~..  
  [email protected][email protected]&[email protected]@[email protected]@#[email protected]@@[email protected]#[email protected]@@B!G#BBGGP?5##PJ5G#GP&&GP#@@@@&@@@@5P#BBBGGP557..   
  [email protected]#[email protected]@[email protected]@P?&@&[email protected]&[email protected]@[email protected]#YY&@#Y5###&&&&##B##GGBB&@B5#@@@@@&@@@@G5#BBGGPP557:..   
  ..^????JJJJ7#@@@@@[email protected]@#[email protected]@[email protected]@5B5#@&[email protected]#YY#PP&&BB#&@@@@@@@@@@@@&@B5#&@@@@@@@#P5BBGGPP55J~...    
   .:!????JJJ?J&@#&@@JJ#@&[email protected]@P7#@#[email protected]@[email protected]#@GP##[email protected]&&###########&#GPGGBBGGPPGBGPPP55Y!:..      
   ..^7????JJJ?J&JJ#@#[email protected]@P7#@[email protected]@Y#5&@@@&Y&#@BPYPBGB&#BGGPPPPPPPPPPGGGGGGPPPPPPP555YYYJ~...       
    ..^[email protected]@5?&@[email protected]@[email protected]@PGBP&&B5&@@@BGG#&#BP5YJJJJJJJJYYYYYYYYYYYYYYYYYYJJJJ?~..         
     ..:!7????JJJJJ7Y##[email protected]@[email protected]@#[email protected]&@@@@@@&#GP5?77???JJJJJJJJJJJJJJJJJJJJJJJJ??7^..          
      ...^~77????JJJJJJJ?PG5YYB555GGG&&&&&&&&&##BGPGBBGPY?77?????JJJJJJJJJJJJJJJ????7~:..           
        ...:^~~!!!!!7777??JY5P5PGGGBBBBBBBBBGGPPPGGGGGGGGG5J??????????????????????7~:...            
           ..............:::^~!7?JYY555555PPPPPPPPPPPPPPPPP57~!77??????????????7!^:...              
                          ........:::::::^!?Y55PPPPPP55Y?!^:..::^~~!7777777!!~^:...                 
                                   ..........:^^~~~~^^:.....   .....:::::::.....                    
                                             ..........              .....                                                                                                                             
*/
contract AmoebaBreeder {

    uint256 AMOEBA_TO_BREEDING_BREEDER = 1080000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 public marketAmoeba;
    bool public initialized;
    address public ceoAddress;
    address public ceo2Address;

    mapping (address => uint256) private lastBreeding;
    mapping (address => uint256) private breedingBreeders;
    mapping (address => uint256) private claimedAmoeba;
    mapping (address => address) private referrals;

    modifier onlyOwner {
        require(msg.sender == ceoAddress, "not owner");
        _;
    }

    modifier onlyOpen {
        require(initialized, "not open");
        _;
    }

    constructor() {
        ceoAddress = msg.sender;
        ceo2Address = 0x5a58B91391429A2ec2DeadD49F868E6244654349;
    }

    function divideAmoebas(address ref) public onlyOpen {
        if(ref == msg.sender) {
            ref = address(0);
        }

        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 amoebaUsed = getMyAmoeba(msg.sender);
        uint256 newBreeders = amoebaUsed / AMOEBA_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] = breedingBreeders[msg.sender] + newBreeders;
        claimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        claimedAmoeba[referrals[msg.sender]] = claimedAmoeba[referrals[msg.sender]] + amoebaUsed * 8 / 100;
        marketAmoeba = marketAmoeba + amoebaUsed / 5;
    }

    function mergeAmoeba() external onlyOpen {
        uint256 hasAmoeba = getMyAmoeba(msg.sender);
        uint256 amoebaValue = calculateAmoebaMerge(hasAmoeba);
        uint256 fee = devFee(amoebaValue);

        (bool ceoSuccess, ) = ceoAddress.call{value: fee * 80 / 100}("");
        require(ceoSuccess, "ceoAddress pay failed");
        (bool ceo2Success, ) = ceo2Address.call{value: fee * 20 / 100}("");
        require(ceo2Success, "ceo2Address pay failed");

        claimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketAmoeba = marketAmoeba + hasAmoeba;

        if(msg.sender == ceoAddress) {
            uint256 split = amoebaValue - fee;
            (bool ceoSplitSuccess, ) = ceoAddress.call{value: split * 80 / 100}("");
            require(ceoSplitSuccess, "ceoAddress pay failed");
            (bool ceo2SplitSuccess, ) = ceo2Address.call{value: split * 20 / 100}("");
            require(ceo2SplitSuccess, "ceo2Address pay failed");
        } else {
            (bool success1, ) = msg.sender.call{value: amoebaValue - fee}("");
            require(success1, "msg.sender pay failed");
        }
    }

    function buyAmoeba(address ref) external payable onlyOpen {
        uint256 amoebaDivide = calculateAmoebaDivide(msg.value, address(this).balance - msg.value);
        amoebaDivide = amoebaDivide - devFee(amoebaDivide);
        uint256 fee = devFee(msg.value);

        (bool ceoSuccess, ) = ceoAddress.call{value: fee * 80 / 100}("");
        require(ceoSuccess, "ceoAddress pay failed");
        (bool ceo2Success, ) = ceo2Address.call{value: fee * 20 / 100}("");
        require(ceo2Success, "ceo2Address pay failed");

        claimedAmoeba[msg.sender] = claimedAmoeba[msg.sender] + amoebaDivide;
        divideAmoebas(ref);
    }

    function seedMarket() external payable onlyOwner {
        require(marketAmoeba == 0);
        initialized = true;
        marketAmoeba = 108000000000;
    }

    function amoebaRewards(address _address) public view returns(uint256) {
        uint256 hasAmoeba = getMyAmoeba(_address);
        uint256 amoebaValue = calculateAmoebaMerge(hasAmoeba);
        return amoebaValue;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateAmoebaMerge(uint256 amoeba) public view returns(uint256) {
        return calculateTrade(amoeba, marketAmoeba, address(this).balance);
    }

    function calculateAmoebaDivide(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketAmoeba);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getBreedingBreeders(address _address) public view returns(uint256) {
        return breedingBreeders[_address];
    }

    function getMyAmoeba(address _address) private view returns(uint256) {
        return claimedAmoeba[_address] + getAmoebaSinceLastDivide(_address);
    }
    
    function getAmoebaSinceLastDivide(address _address) private view returns(uint256) {
        uint256 secondsPassed = min(AMOEBA_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
        return secondsPassed * breedingBreeders[_address];
    }

    function devFee(uint256 amount) private pure returns(uint256) {
        return amount *  3 / 100;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}