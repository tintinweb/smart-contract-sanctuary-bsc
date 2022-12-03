/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

pragma solidity ^0.4.17;

contract mortal {
    /* Define variable owner of the type address */
    address public owner;

    /* This function is executed at initialization and sets the owner of the contract */
    function mortal() public { owner = msg.sender; }
    
    /* Restricted to owner */
    modifier restricted { require(msg.sender == owner); _; }
    
    /* Function to recover the funds on the contract */
    function kill() restricted public { selfdestruct(owner); }
    
    /* Function to transfer ownership */
    function transfer(address _newOwner) restricted public { owner = _newOwner; }
}

contract BlogChain is mortal {
    /* Struct for the Post */
    struct PostStruct {
        string title;
        string content;
        uint256 datetime;
    }
    
    /* ID of the Next Post */
    uint256 private nextPostID = 0;
    
    /* Number of the Posts (Excluding Deleted) */
    uint256 private postsNum = 0;
    
    /* Name of the Blog */
    string public name;
    
    /* Description of the Blog */
    string public description;
    
    /* All Posts */
    mapping(uint256 => PostStruct) public posts;
    
    /* Constructor */
    function BlogChain(string _name, string _description) public {
        name = _name;
        description = _description;
    }
    
    /* Add a Post */
    function addPost(string _title, string _content, uint256 _datetime) restricted public {
        posts[nextPostID].title = _title;
        posts[nextPostID].content = _content;
        posts[nextPostID].datetime = _datetime;
        
        nextPostID ++;
        postsNum ++;
    }
    
    /* Delete a Post */
    function deletePost(uint256 _id) restricted public {
        delete posts[_id];
        
        postsNum --;
    }
    
    /* Edit a Post */
    function editPost(uint256 _id, string _title, string _content) restricted public {
        posts[_id].title = _title;
        posts[_id].content = _content;
    }
    
    /* Get Number of the Posts (Including Deleted) */
    function getNumberOfPostsDeleted() public constant returns (uint256) {
        return nextPostID;
    }
    
    /* Get Number of the Posts (Excluding Deleted) */
    function getNumberOfPosts() public constant returns (uint256) {
        return postsNum;
    }
}