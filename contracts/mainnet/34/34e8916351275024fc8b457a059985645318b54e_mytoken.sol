// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./ERC20.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract mytoken is ERC20{
    uint32 public time = uint32(block.timestamp);
    uint112 public constant max_token_number =37000000 ether;  //发行总量
    uint112 public constant all_claim = max_token_number/2;  //空投总量
    uint16 the_number_of_claim = 0;//
    mapping(address => bool) public is_claim;


    constructor() ERC20("liuxin","lx02"){
        _mint(0x906db168723a964b5276e0008A164c4f054cEe92,max_token_number/2);
    }

    //实现空投功能的3个函数，就是说用3个函数来实现空投功能

    function claim() public {
        if(block.timestamp - time <= 360 days && return_is_claim(msg.sender) == false){
            the_number_of_claim +=1;
            is_claim[msg.sender] = true;
            _mint(msg.sender,return_claim_number());

        }

    }

    function return_claim_number() public view returns(uint104){
        uint104 claim_number;

        if(the_number_of_claim <= 1010){
            claim_number = uint104(all_claim/100*20/1010*1);
        }

        else if(the_number_of_claim > 1010 && the_number_of_claim <= 101010){
            claim_number = uint104((all_claim/100*80)/100000*1);
        }

        return claim_number;
    }

     function return_is_claim(address _address) public view returns(bool){
       return is_claim[_address];
    }

}