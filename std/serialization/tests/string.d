/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module std.serialization.tests.string;

version (unittest):
private:

import std.serialization.serializer;
import std.serialization.archives.xmlarchive;
import std.serialization.tests.util;
import std.traits;

Serializer serializer;
XmlArchive!(char) archive;

class C
{
	string str;
	wstring wstr;
	dstring dstr;
}

C c;
C u;

void beforeEach ()
{
    archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	c = new C;
	c.str = "foo";
	c.wstr = "bar";
	c.dstr = "foobar";

    serializer.serialize(c);
}

void beforeEachUnicode ()
{
    archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

    u = new C;
	u.str = "foo åäö";
	u.wstr = "foo ÅÄÖ";
	u.dstr = "foo åäö ÅÄÖ";

    serializer.serialize(u);
}

@describe("serialize strings")
{
	@it("should return serialized strings") unittest
	{
		beforeEach();

		assert(archive.data().containsDefaultXmlContent());
		assert(archive.data().containsXmlTag("object", `runtimeType="` ~ typeid(C).toString() ~ `" type="` ~ fullyQualifiedName!(C) ~ `" key="0" id="0"`));
		assert(archive.data().containsXmlTag("string", `type="immutable(char)" length="3" key="str" id="1"`, "foo"));
		assert(archive.data().containsXmlTag("string", `type="immutable(wchar)" length="3" key="wstr" id="2"`, "bar"));
		assert(archive.data().containsXmlTag("string", `type="immutable(dchar)" length="6" key="dstr" id="3"`, "foobar"));
	}
}

@describe("deserialize string")
{
	@it("should return a deserialized string equal to the original string") unittest
	{
	    beforeEach();

		auto cDeserialized = serializer.deserialize!(C)(archive.untypedData);

		assert(c.str == cDeserialized.str);
		assert(c.wstr == cDeserialized.wstr);
		assert(c.dstr == cDeserialized.dstr);
	}
}

@describe("serialize Unicode strings")
{
	@it("should return a serialized string containing proper Unicode") unittest
	{
		beforeEachUnicode();

		assert(archive.data().containsDefaultXmlContent());
		assert(archive.data().containsXmlTag("object", `runtimeType="` ~ typeid(C).toString() ~ `" type="` ~ fullyQualifiedName!(C) ~ `" key="0" id="0"`));
		assert(archive.data().containsXmlTag("string", `type="immutable(char)" length="10" key="str" id="1"`, "foo åäö"));
		assert(archive.data().containsXmlTag("string", `type="immutable(wchar)" length="7" key="wstr" id="2"`, "foo ÅÄÖ"));
		assert(archive.data().containsXmlTag("string", `type="immutable(dchar)" length="11" key="dstr" id="3"`, "foo åäö ÅÄÖ"));
	}
}

@describe("deserialize Unicode string")
{
	@it("should return a deserialize Unicode string equal to the original strings") unittest
	{
	    beforeEachUnicode();

		auto uDeserialized = serializer.deserialize!(C)(archive.untypedData);

		assert(u.str == uDeserialized.str);
		assert(u.wstr == uDeserialized.wstr);
		assert(u.dstr == uDeserialized.dstr);
	}
}