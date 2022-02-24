/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// File: Stacking/stackngwo.sol


pragma solidity ^0.8.0;


interface AwesomeNfts {
    function stackMoreNFT(uint _tokenId, address _from) external returns(bool); 
    function unStackMoreNFT(uint _tokenId, address _from) external returns(bool);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function walletOfOwner(address _owner)                            
    external
    view
    returns (uint256[] memory);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract NftStacking {
    uint public duration; //set duration for all the unsumers;
    mapping(address => Stack) public stackingUsers; //it's hold all the stacking users;
    mapping(address => Token[]) public userTokens;
    address public ContractAddress;
    address public CoinContractAddress;
    Token[] private temp;
    
    struct Stack {
        uint [] tokens;
        uint startTime;
        uint nftPrice;
        uint rewardTime;    
    }

    struct Token {
        uint tokenId;
        uint start;
        uint reward;
        uint price;
    }
   
    struct Days {
        uint remain;
        uint current;
        uint least;
    }

    struct Check {
        Days day;
        uint fund;
    }


    function stackOneNft(
        uint _token,
        address _user,
        uint _price
    ) public returns(bool) {
        AwesomeNfts an = AwesomeNfts(ContractAddress);
        delete temp;
        temp = userTokens[_user];
        address _currentUser = an.ownerOf(_token);
        require(_user == _currentUser, "Invalid Token Id");
        for (uint a = 0 ; a < temp.length; a++) {
            require(temp[a].tokenId != _token, "Token Already Stacked");
        }
        Token memory token = Token(_token, block.timestamp, block.timestamp, _price);
        temp.push(token);
        userTokens[_user] = temp;
        an.stackMoreNFT(_token, _user);
        return true;
    }

    function unStackNft(
        address _user,
        uint _token
    ) public returns(bool) {
        AwesomeNfts an = AwesomeNfts(ContractAddress);
        delete temp;
        temp = userTokens[_user];

        for(uint i=0; i<temp.length; i++) {
            if(temp[i].tokenId == _token) {
                an.unStackMoreNFT(temp[i].tokenId, _user);
                delete temp[i];
            }
        }

        if(temp.length == 0) {
            delete userTokens[_user];
        }
        userTokens[_user] = temp;
        return true;
    }


    function claimReward(
        address _user,
        uint _token
    ) public returns(Check memory) {
        delete temp;
        temp = userTokens[_user];
        Check memory check;

        for(uint i=0; i < temp.length; i++) {
            if(temp[i].tokenId == _token) {
                require(temp[i].reward + 1 minutes < block.timestamp, "Claim Reward Duration Is Not Over");
                Days memory d = differenceInDays(temp[i].reward, block.timestamp);
                uint share =  getShares(temp[i].price);
                uint daysOfMonths = d.least * share;

                if(d.current > 0) {
                    temp[i].reward = d.current;
                } 

                check = Check(d, daysOfMonths);
                break;
            }
        }

        userTokens[_user] = temp;
        return check;
    }

     function getShares(uint _price) private pure returns (uint) {
         uint percent = 0;

         if(_price <= 50) {
             percent = (_price * 22) / 100;
         } else if((_price > 50) && (_price <= 200)) {
             percent = (_price * 25) / 100;
         } else if((_price > 200) && (_price <= 600)) {
             percent = (_price * 28) / 100;
         }

         return percent;
     }

     function differenceInDays(uint _startTime, uint _endTime) internal pure returns(Days memory) {
        uint day = ((_endTime - _startTime) / 5 minutes); 
        uint t = 5;
        if(day > 5) {
            uint last = 0;
            for(uint i=0; i < 10; i++) {
                if(day >= (t * i)) {
                    last = t * i;
                } else {
                    uint remain = day - last;
                    uint ntime = 5 minutes * remain;
                    uint newDay = _endTime + ntime;
                    Days memory s = Days(remain, newDay, last);//  es  1643369530  st 1643365025
                    return s;
                }
            }
        }
        // return 0
    }

   

    // function unStackOneNFT(
    //     uint _tokenId,
    //     address _user
    // ) public returns(bool) {
    //     Stack memory stack = stackingUsers[_user];
    //     uint [] memory st = stack.tokens;

    //     for(uint i = 0; i < st.length; i++) {
    //         if(st[i] == _tokenId) {
    //             an.unStackMoreNFT(_tokenId, _user);
    //             delete st[i];
    //         }
    //     }

    //     require(st.length > 0,"Please Use All nft UnSack method");
    //     Stack memory s = Stack(st, stack.startTime, stack.nftPrice, stack.rewardTime);
    //     stackingUsers[_user] = s;
    //     return true;
    // }


     function TransferCheck(address _user, uint rewardAmount) internal {
            IERC20 c = IERC20(CoinContractAddress);
            c.transfer(_user, rewardAmount);
     }

    function setContractAddress(
        address _contractAddress
    ) public {
        ContractAddress = _contractAddress;
    }

    function setCoinContractAddress(
        address _contractAddress,
        uint _price
    ) public {
        CoinContractAddress = _contractAddress;
        IERC20 coin = IERC20(CoinContractAddress);
        coin.approve(address(this), _price);
    }

    function getCointInfo(
        address _contractAddress
    ) public view returns(uint) {
        IERC20 coin = IERC20(CoinContractAddress);
        return coin.balanceOf(_contractAddress);
    }

    function setDuration(
        uint _time
    ) public {
        duration = _time;
    }

}