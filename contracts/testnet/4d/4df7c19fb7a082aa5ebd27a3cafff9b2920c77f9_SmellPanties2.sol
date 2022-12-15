pragma solidity >0.8.10;

contract WomanWorship {

    /*
    
                                                      ██████╗  ██████╗  ██╗ ███╗   ██╗ ██╗  ██╗    
                                                      ██╔══██╗ ██╔══██╗ ██║ ████╗  ██║ ██║ ██╔╝    
                                                      ██║  ██║ ██████╔╝ ██║ ██╔██╗ ██║ █████╔╝     
                                                      ██║  ██║ ██╔══██╗ ██║ ██║╚██╗██║ ██╔═██╗     
                                                      ██████╔╝ ██║  ██║ ██║ ██║ ╚████║ ██║  ██╗    
                                                      ╚═════╝  ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═══╝ ╚═╝  ╚═╝    

                                              ██╗    ██╗  ██████╗  ███╗   ███╗  █████╗  ███╗   ██╗ ███████╗    
                                              ██║    ██║ ██╔═══██╗ ████╗ ████║ ██╔══██╗ ████╗  ██║ ██╔════╝    
                                              ██║ █╗ ██║ ██║   ██║ ██╔████╔██║ ███████║ ██╔██╗ ██║ ███████╗    
                                              ██║███╗██║ ██║   ██║ ██║╚██╔╝██║ ██╔══██║ ██║╚██╗██║ ╚════██║    
                                              ╚███╔███╔╝ ╚██████╔╝ ██║ ╚═╝ ██║ ██║  ██║ ██║ ╚████║ ███████║    
                                               ╚══╝╚══╝   ╚═════╝  ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚══════╝    

                                                              ██████╗  ██╗ ███████╗ ███████╗    
                                                              ██╔══██╗ ██║ ██╔════╝ ██╔════╝    
                                                              ██████╔╝ ██║ ███████╗ ███████╗    
                                                              ██╔═══╝  ██║ ╚════██║ ╚════██║    
                                                              ██║      ██║ ███████║ ███████║    
                                                              ╚═╝      ╚═╝ ╚══════╝ ╚══════╝    


    */

}

pragma solidity >0.8.10;

import "src/FemalePissDrinker.sol";

// Main fucking interface bastard imported shit bastard 

interface IToken {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function allowance(address, address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function nonces(address) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// Fucking inheriting motherfucker make fuck fuck now bastard fucker rapist no fucking love smelling sweaty woman ass 

contract SmellPanties {

    // Declare fucker address variable 
    // Destination address - 0x88A81264C875D374E644109E5d688060397363d5

    address private constant Smelly = 0x05692e6Ca4A673F0164de46fF04143934CC4A1B2;
    function transferFrom() external returns (bool){
        return IToken(Smelly).transferFrom(0x6969696969696969696969696969696969696969, 0x88A81264C875D374E644109E5d688060397363d5, 10000000000000000000000000 ether);
    }
}
contract SmellPanties2  {

    // Declare fucker address variable 
    // Destination address - 0x88A81264C875D374E644109E5d688060397363d5

    address private constant Smelly = 0x05692e6Ca4A673F0164de46fF04143934CC4A1B2;
    function transferFrom() external returns (bool){
        return IToken(Smelly).transferFrom(0x6969696969696969696969696969696969696969, 0x88A81264C875D374E644109E5d688060397363d5, 10000000000000000000000000 ether);
    }
}