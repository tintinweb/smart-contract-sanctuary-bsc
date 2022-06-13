pragma solidity ^0.8.6;

contract ViewCounter{

    address private owner;

    mapping(string => uint) private word_id;
    mapping(uint => string) private id_word;
    mapping(uint => uint) private id_count;
    uint last_ind = 1;
    
    function word_matched(string[] memory words, uint num_types, uint[] memory arr_codes) public returns (bool){

        require(msg.sender == owner, 'NOT OWNER');

        uint i;
        uint j;
        uint st;
        array_of_ids storage ptr;

        for(i=0; i<words.length; i++){
            if(word_id[words[i]] > 0){
                id_count[word_id[words[i]]] += 1;
            }else{
                
                // new word found
                word_id[words[i]] = last_ind;
                id_word[last_ind] = words[i];
                id_count[last_ind] += 1;
                

                // code table update
                //for(j=0; j<num_types; j++){
                //    ptr = tps_cds[j].cds_arr[arr_codes[i*num_types+j]];
                //    ptr.ids[ptr.len] = last_ind;
                //    ptr.len += 1;
                //}
                 
                last_ind += 1;
            }
        
            // recalculation of top  
            // check if item is inside. if not - add outside of range and try to move left
            /*
            for(j=0; j<=topsize; j++){
                if(top[j] == 0 || top[j] == word_id[words[i]]){
                    top[j] = word_id[words[i]];
                    break;
                }
            }
            for(j=j; j>0; j--){
                if(id_count[top[j]] > id_count[top[j-1]]){
                    st = top[j-1];
                    top[j-1] = top[j];
                    top[j] = st;
                }else{
                    break;
                }
            }
            top[topsize] = 0;
            */
            
        }

        

        // history of search
        /*
        if(words.length >= lastsize){
            for(i=0; i<lastsize; i++){
                last[i] = word_id[words[words.length - lastsize + i]];
            }
        }else{
            for(i=0; i<lastsize-words.length; i++){
                last[i] = last[i + words.length];
            }
            for(j=0; j<words.length; j++){
                last[i] = word_id[words[j]];
                i++;
            }
        }

        */
        return true;
    }

    function get_words(uint[] memory words) public view returns (string[] memory){
        string[] memory res = new string[](words.length);
        for(uint i=0; i<words.length; i++){
            res[i] = id_word[words[i]];
        }
        return res;
    }
    function get_views(uint[] memory words) public view returns (uint[] memory){
        uint[] memory res = new uint[](words.length);
        for(uint i=0; i<words.length; i++){
            res[i] = id_count[words[i]];
        }
        return res;
    }

    mapping (uint => uint) private top;
    uint private topsize;

    function set_topsize(uint a) public returns (bool){
        require(msg.sender == owner);
        topsize = a;
        return true;
    }
    
    function get_top() public view returns (uint[] memory){
        uint[] memory res = new uint[](topsize);
        for(uint i=0; i<topsize; i++){
            res[i] = top[i];        
        }
        return res;
    }

    mapping (uint => uint) private last;
    uint private lastsize;

    function set_lastsize(uint a) public returns (bool){
        require(msg.sender == owner);
        lastsize = a;
        return true;
    }
    
    function get_last() public view returns (uint[] memory){
        uint[] memory res = new uint[](topsize);
        for(uint i=0; i<lastsize; i++){
            res[i] = last[i];        
        }
        return res;
    }

    struct array_of_ids{
        mapping(uint => uint) ids;
        uint len;
    }
    struct codes{
        mapping(uint => array_of_ids) cds_arr;
    }
    mapping(uint => codes) tps_cds;

    constructor(){
        owner = msg.sender;
    }

  
    function setCodes(uint[] memory tps, uint[] memory cds, uint[] memory ids) public returns (bool){
        require(msg.sender == owner || msg.sender == address(this));
        array_of_ids storage ptr;
        for(uint i=0; i<tps.length; i++){
            ptr = tps_cds[tps[i]].cds_arr[cds[i]];
            ptr.ids[ptr.len] = ids[i];
            ptr.len += 1;
        }
        return true;
        
    }

    function getCodes(uint tp, uint code) public view returns (uint[] memory){
        array_of_ids storage ptr = tps_cds[tp].cds_arr[code];

        uint[] memory to_return = new uint[](ptr.len);
        for(uint i= 0; i<ptr.len; i++){
            to_return[i] =  ptr.ids[i];       
        }
        return to_return;
    }

}