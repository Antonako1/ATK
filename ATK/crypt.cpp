﻿#include <string>
#include <vector>

#include "cryption.h"
#include "argHeader.h"

/**
 * Crypts given content.
 * Turns characters to UTF8 Decimals and 
 * changes some values
 * 
 * @param content String to be crypted
*/

std::vector<char32_t> crypt(std::string content, basicInfo* result){
    // Holds the final string full of unicode characters

    // Vector to store Unicode characters
    std::vector<char32_t> results;
    int cypher = cypherAmount(result);
    // Loops through the content string
    for (char32_t c : content) {

        // If c is under 149,813
        // https://www.unicode.org/versions/Unicode15.1.0/
        // MAXIMUM AMOUNT AS OF UNICODE 15.1.0
        if (c + cypher > 149813) {

        } else {
            // Pushes to the back of the vector
            // And adds cypher amount
            results.push_back(c + cypher);

        }
    }
    return results;
}