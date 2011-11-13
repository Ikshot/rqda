/*
Rewritten by ronggui huang on 18 Sep. 2011
Based on the Complex example
 */
package Rmmseg4j;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;

import com.chenlb.mmseg4j.ComplexSeg;
import com.chenlb.mmseg4j.Dictionary;
import com.chenlb.mmseg4j.MMSeg;
import com.chenlb.mmseg4j.Seg;
import com.chenlb.mmseg4j.Word;

public class Rmmseg {

    protected Dictionary dic;

    public Rmmseg() {
        dic = Dictionary.getInstance();
    }

    protected Seg getSeg() {
        return new ComplexSeg(dic);
    }

    public String segWords(Reader input, String wordSpilt) throws IOException {
        StringBuilder sb = new StringBuilder();
        Seg seg = getSeg();	//取得不同的分词具体算法
        MMSeg mmSeg = new MMSeg(input, seg);
        Word word = null;
        boolean first = true;
        while ((word = mmSeg.next()) != null) {
            if (!first) {
                sb.append(wordSpilt);
            }
            String w = word.getString();
            sb.append(w);
            first = false;
        }
        return sb.toString();
    }

    public String segWords(String txt, String wordSpilt) throws IOException {
        return segWords(new StringReader(txt), wordSpilt);
    }

    protected String run(String txt) throws IOException {
        return segWords(txt, " ");
    }

    public static void main(String[] args) throws IOException {
        String txt = "";
	if (args.length == 0) {
	    System.out.println("Usage:\n Rmmseg4j text");
	}
        if (args.length > 0) {
            txt = args[0];
        }
        System.out.println(new Rmmseg().run(txt));
    }

    private String textMethod(String txt) throws IOException {
        String res = "";
        res = new Rmmseg().run(txt);
        return res;
    }
}